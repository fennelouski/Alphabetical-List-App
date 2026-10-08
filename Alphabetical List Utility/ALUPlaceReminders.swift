import CoreLocation
import MapKit
import UserNotifications
import UIKit

private struct NearbyNotePlace: Codable {
    let identifier: String
    let title: String
    let query: String
    let name: String
    let latitude: Double
    let longitude: Double
}

@objc(ALUPlaceReminders)
public final class ALUPlaceReminders: NSObject, CLLocationManagerDelegate, ObservableObject {
    @objc public static let shared = ALUPlaceReminders()
    @Published private(set) var enabled = UserDefaults.standard.bool(forKey: "ALUNearbyRemindersEnabled")
    @Published private(set) var status = "Nearby reminders are off."
    @Published private(set) var places: [String] = []
    private let manager = CLLocationManager()
    private var loadNotes: (() -> [[String: String]])?
    private var cached: [NearbyNotePlace] = []
    private var lastSearchLocation: CLLocation?
    private var lastSearchDate = Date.distantPast
    private var searching = false
    private var requestedAlways = false
    private var revision = 0
    private var searchedIntents = Set<String>()
    private var notifiedThisVisit = Set<String>()
    private let prefix = "AtoZNearby:"

    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        if let data = UserDefaults.standard.data(forKey: "ALUNearbyPlaces.v1") {
            cached = (try? JSONDecoder().decode([NearbyNotePlace].self, from: data)) ?? []
        }
        NotificationCenter.default.addObserver(self, selector: #selector(notesChanged), name: .init("ALULibraryChanged"), object: nil)
    }

    @objc(startWithNotes:)
    public func start(notes: @escaping () -> [[String: String]]) {
        loadNotes = notes
        let action = UNNotificationAction(identifier: "showNote", title: "Show Note", options: .foreground)
        UNUserNotificationCenter.current().setNotificationCategories([UNNotificationCategory(identifier: "showNoteNotificationCategory", actions: [action], intentIdentifiers: [], options: [])])
        resume()
    }

    func setEnabled(_ value: Bool) {
        enabled = value
        UserDefaults.standard.set(value, forKey: "ALUNearbyRemindersEnabled")
        revision += 1
        if value {
            lastSearchDate = .distantPast
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
                DispatchQueue.main.async { self.resume() }
            }
            if manager.authorizationStatus == .notDetermined { manager.requestWhenInUseAuthorization() }
            else if manager.authorizationStatus == .authorizedWhenInUse { manager.requestAlwaysAuthorization() }
            resume()
        } else {
            manager.stopMonitoringSignificantLocationChanges()
            for region in manager.monitoredRegions where region.identifier.hasPrefix(prefix) { manager.stopMonitoring(for: region) }
            cached = []
            saveCache()
            status = "Nearby reminders are off."
        }
    }

    @objc public func resume() {
        guard enabled else { return }
        let authorization = manager.authorizationStatus
        guard authorization == .authorizedAlways || authorization == .authorizedWhenInUse else {
            status = "Allow location access in Settings to find nearby stores."
            return
        }
        if authorization == .authorizedAlways && CLLocationManager.significantLocationChangeMonitoringAvailable() {
            manager.startMonitoringSignificantLocationChanges()
        }
        status = authorization == .authorizedAlways ? "Looking for nearby places…" : "Allow Always location access for reminders while AtoZ is closed."
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .denied {
                DispatchQueue.main.async { self.status = "Allow notifications in Settings to receive nearby reminders." }
            }
        }
        manager.requestLocation()
    }

    @objc private func notesChanged() {
        let changed = intentSignature() != searchedIntents
        if changed { revision += 1 }
        // Remove stale fences immediately. A background callback must also recheck the note.
        let titles = Set((loadNotes?() ?? []).compactMap { $0["title"] })
        cached.removeAll { !titles.contains($0.title) || intent(for: $0.title)?.query != $0.query }
        saveCache()
        installRegions()
        if enabled && changed { lastSearchDate = .distantPast; manager.requestLocation() }
    }

    private func intentSignature() -> Set<String> {
        Set((loadNotes?() ?? []).compactMap { note in
            guard let title = note["title"], let intent = intent(for: title) else { return nil }
            return title + "\u{0}" + intent.query
        })
    }

    private func intent(for title: String) -> NotePlaceIntent? {
        guard let note = loadNotes?().first(where: { $0["title"] == title }) else { return nil }
        return NotePlaceIntent.infer(title: title, text: note["text"] ?? "", details: ALUNoteDetailsStore.shared.ensure(title))
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if enabled && manager.authorizationStatus == .authorizedWhenInUse && !requestedAlways {
            requestedAlways = true
            manager.requestAlwaysAuthorization()
        }
        resume()
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if enabled { status = "Location unavailable. Nearby reminders will retry when location returns." }
    }
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard enabled, let location = locations.last, location.horizontalAccuracy >= 0,
              location.horizontalAccuracy <= 1000, abs(location.timestamp.timeIntervalSinceNow) < 120 else { return }
        if searching { return }
        if Date().timeIntervalSince(lastSearchDate) < 900,
           let previous = lastSearchLocation, location.distance(from: previous) < 3000 { return }
        search(near: location)
    }

    private func search(near location: CLLocation) {
        searchedIntents = intentSignature()
        let notes = (loadNotes?() ?? []).compactMap { note -> (String, NotePlaceIntent)? in
            guard let title = note["title"], let intent = intent(for: title) else { return nil }
            return (title, intent)
        }
        guard !notes.isEmpty else {
            cached = []; saveCache(); installRegions()
            status = "Name a shopping note for a store, or choose a place in Note Details."
            return
        }
        searching = true
        let startedRevision = revision
        lastSearchDate = Date(); lastSearchLocation = location
        // Search once per distinct store, sequentially, rather than once per note.
        let queries = Array(Set(notes.map { $0.1.query })).sorted()
        var results: [NearbyNotePlace] = []
        func next(_ position: Int) {
            guard enabled, startedRevision == revision else { searching = false; resume(); return }
            guard position < queries.count else {
                searching = false
                cached = results.sorted {
                    CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: location) <
                    CLLocation(latitude: $1.latitude, longitude: $1.longitude).distance(from: location)
                }
                saveCache(); installRegions()
                status = cached.isEmpty ? "No matching stores nearby. AtoZ will look again as you move." : "\(places.count) nearby places monitored."
                return
            }
            let query = queries[position]
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.resultTypes = .pointOfInterest
            request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 40000, longitudinalMeters: 40000)
            MKLocalSearch(request: request).start { response, error in
                DispatchQueue.main.async {
                    if let response {
                        for item in response.mapItems {
                            let coordinate = item.placemark.coordinate
                            let distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: location)
                            guard CLLocationCoordinate2DIsValid(coordinate), distance <= 20000 else { continue }
                            for (title, intent) in notes where intent.query == query && intent.matchesPlaceName(item.name ?? "") {
                                let noteID = ALUNoteDetailsStore.shared.identifier(forTitle: title)
                                let identifier = self.prefix + noteID + String(format: ":%.5f:%.5f", coordinate.latitude, coordinate.longitude)
                                if !results.contains(where: { $0.identifier == identifier }) {
                                    results.append(NearbyNotePlace(identifier: identifier, title: title, query: query, name: item.name ?? query, latitude: coordinate.latitude, longitude: coordinate.longitude))
                                }
                            }
                        }
                    } else if error != nil {
                        // Keep still-valid cached stores during an offline search.
                        results.append(contentsOf: self.cached.filter { $0.query == query && self.intent(for: $0.title)?.query == query })
                    }
                    next(position + 1)
                }
            }
        }
        next(0)
    }

    private func saveCache() {
        if let data = try? JSONEncoder().encode(cached) { UserDefaults.standard.set(data, forKey: "ALUNearbyPlaces.v1") }
    }

    private func installRegions() {
        guard enabled else { places = []; return }
        let manualCount = manager.monitoredRegions.filter { !$0.identifier.hasPrefix(prefix) }.count
        let chosen = Array(cached.prefix(max(0, 20 - manualCount)))
        let identifiers = Set(chosen.map { $0.identifier })
        for region in manager.monitoredRegions where region.identifier.hasPrefix(prefix) && !identifiers.contains(region.identifier) {
            manager.stopMonitoring(for: region)
        }
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            for place in chosen where !manager.monitoredRegions.contains(where: { $0.identifier == place.identifier }) {
                let radius = min(200, manager.maximumRegionMonitoringDistance)
                guard radius > 0 else { continue }
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude), radius: radius, identifier: place.identifier)
                region.notifyOnEntry = true; region.notifyOnExit = true
                manager.startMonitoring(for: region)
                manager.requestState(for: region)
            }
        }
        places = chosen.map { $0.name + " · " + $0.title }
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) { handleRegion(identifier: region.identifier) }
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside { handleRegion(identifier: region.identifier) }
    }
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) { notifiedThisVisit.remove(region.identifier) }
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        status = "A location reminder could not be monitored. Check location access and try again."
    }

    @objc(handleRegionWithIdentifier:)
    public func handleRegion(identifier: String) {
        let automatic = identifier.hasPrefix(prefix)
        let place = cached.first { $0.identifier == identifier }
        let title: String
        if automatic {
            guard enabled, let place, intent(for: place.title)?.query == place.query,
                  !notifiedThisVisit.contains(identifier) else { return }
            title = place.title
        } else {
            title = identifier
            guard UserDefaults.standard.double(forKey: title + "radiusInMetersK£y") > 0,
                  UserDefaults.standard.bool(forKey: title + "notificationEnabledK£y") else { return }
        }
        guard let note = loadNotes?().first(where: { $0["title"] == title }) else { return }
        let noteID = ALUNoteDetailsStore.shared.identifier(forTitle: title)
        let key = "ALUNearbyLastNotification:" + noteID
        if let last = UserDefaults.standard.object(forKey: key) as? Date, Date().timeIntervalSince(last) < 600 { return }
        notifiedThisVisit.insert(identifier)
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = place.map { "Near " + $0.name } ?? "Location reminder"
        content.body = (note["text"] ?? "").components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.prefix(5).joined(separator: "\n")
        content.sound = .default
        content.categoryIdentifier = "showNoteNotificationCategory"
        content.userInfo = ["noteTitle": title, "noteID": noteID]
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "AtoZReminder:" + noteID, content: content, trigger: nil)) { error in
            DispatchQueue.main.async {
                if error == nil { UserDefaults.standard.set(Date(), forKey: key) }
                else { self.notifiedThisVisit.remove(identifier); self.status = "The reminder could not be delivered." }
            }
        }
    }
}
