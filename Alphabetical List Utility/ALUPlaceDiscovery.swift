import Foundation
import MapKit

struct NotePlaceIntent: Equatable {
    let query: String
    let automatic: Bool

    // Aliases handle real Maps business names; the business directory itself is Apple Maps.
    private static let aliases = ["costco wholesale": "Costco", "costco business center": "Costco", "starbucks coffee company": "Starbucks", "whole foods": "Whole Foods Market", "home depot": "The Home Depot", "cvs": "CVS Pharmacy", "trader joes": "Trader Joe's", "albert heijn": "Albert Heijn", "sainsburys": "Sainsbury's"]
    private static let categories: [String: MKPointOfInterestCategory] = [
        "grocery store": .foodMarket, "groceries": .foodMarket, "supermarket": .foodMarket, "boodschappen": .foodMarket,
        "pharmacy": .pharmacy, "apotheek": .pharmacy, "library": .library, "bibliotheek": .library,
        "gym": .fitnessCenter, "sportschool": .fitnessCenter, "post office": .postOffice, "bank": .bank,
        "cafe": .cafe, "coffee shop": .cafe, "restaurant": .restaurant, "gas station": .gasStation, "petrol station": .gasStation,
        "park": .park, "airport": .airport, "hospital": .hospital, "school": .school, "university": .university
    ]
    private static let products = Set("milk bread eggs cheese yogurt butter coffee tea rice pasta cereal fruit apple banana vegetables tomato potato onion lettuce chicken fish meat groceries batteries charger toothpaste shampoo soap detergent towel paper toilet socks shoes shirt clothing nappies diapers wipes medicine vitamins paint screws wood furniture lamp desk pillow curtains notebook pencils printer headphones television melk brood eieren kaas koffie rijst boodschappen zeep batterijen".split(separator: " ").map(String.init))
    private static let actions = Set("buy purchase collect shopping order return borrow visit pickup ophalen kopen afhalen bezoeken lenen".split(separator: " ").map(String.init))

    private static func normalized(_ value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .replacingOccurrences(of: "’", with: "").replacingOccurrences(of: "'", with: "")
            .components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }.joined(separator: " ")
    }

    static func infer(title: String, text: String, details: NoteDetails) -> NotePlaceIntent? {
        guard !details.nearbyDisabled else { return nil }
        if let query = details.placeQuery?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty {
            return NotePlaceIntent(query: query, automatic: false)
        }
        var candidate = title.trimmingCharacters(in: .whitespacesAndNewlines)
        var explicitErrand = false
        for prefix in ["shopping at ", "shopping - ", "errands at "] where candidate.lowercased().hasPrefix(prefix) {
            candidate = String(candidate.dropFirst(prefix.count)); explicitErrand = true
            break
        }
        for suffix in [" shopping list", " shopping", " list"] where candidate.lowercased().hasSuffix(suffix) {
            candidate = String(candidate.dropLast(suffix.count)); explicitErrand = true
            break
        }
        let name = normalized(candidate)
        guard (2...80).contains(candidate.count), !candidate.contains("\n"), !candidate.contains(":"),
              !candidate.contains("@"), !candidate.contains("/"), !name.isEmpty,
              !["target practice", "target field", "notes", "shopping", "shopping list", "to do", "todo", "gift ideas"].contains(name) else { return nil }
        let active = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { line in
            !line.isEmpty && !line.hasPrefix("✓") && !line.hasPrefix("☑") &&
            line.range(of: #"^(?:[-*•]\s*)?\[[xX✓]\]"#, options: .regularExpression) == nil
        }
        guard !active.isEmpty else { return nil }
        if explicitErrand || categories[name] != nil { return NotePlaceIntent(query: candidate, automatic: true) }
        let tokens = normalized(active.joined(separator: " ")).split(separator: " ").map(String.init)
        let words = Set(tokens + tokens.filter { $0.count > 3 && $0.hasSuffix("s") }.map { String($0.dropLast()) })
        // ponytail: English/Dutch task vocabulary; add locales when note-language support expands.
        guard !products.isDisjoint(with: words) || !actions.isDisjoint(with: words) || words.contains("pick") && words.contains("up") else { return nil }
        return NotePlaceIntent(query: aliases[name] ?? candidate, automatic: true)
    }

    func matchesPlaceName(_ name: String) -> Bool {
        let name = Self.normalized(name)
        let query = Self.normalized(query)
        let canonicalName = Self.normalized(Self.aliases[name] ?? name)
        let canonicalQuery = Self.normalized(Self.aliases[query] ?? query)
        let withoutThe = canonicalQuery.hasPrefix("the ") ? String(canonicalQuery.dropFirst(4)) : canonicalQuery
        return canonicalName == canonicalQuery || canonicalName == withoutThe ||
            ["store", "superstore", "supercenter", "grocery", "market", "pharmacy", "express", "wholesale", "business center", "coffee company", "neighborhood market"].contains { canonicalName == canonicalQuery + " " + $0 }
    }

    static func searchRequest(query: String, near location: CLLocation) -> MKLocalSearch.Request {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 40000, longitudinalMeters: 40000)
        if #available(iOS 18.0, macOS 15.0, *) { request.regionPriority = .required }
        if let category = categories[normalized(query)] { request.pointOfInterestFilter = MKPointOfInterestFilter(including: [category]) }
        return request
    }

    func matches(_ item: MKMapItem, near location: CLLocation) -> Bool {
        let coordinate: CLLocationCoordinate2D
        if #available(iOS 26.0, macOS 26.0, *) { coordinate = item.location.coordinate }
        else { coordinate = item.placemark.coordinate }
        guard CLLocationCoordinate2DIsValid(coordinate),
              CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: location) <= 20000 else { return false }
        if let category = Self.categories[Self.normalized(query)] { return item.pointOfInterestCategory == category }
        // User-chosen queries may contain an address rather than the business's exact name.
        return !automatic || matchesPlaceName(item.name ?? "")
    }
}
