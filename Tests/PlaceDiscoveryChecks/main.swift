import Foundation
import MapKit

let near = CLLocation(latitude: 37.3230, longitude: -122.0322) // Public Cupertino center, not the owner's location.
let cases = [("Target", "Milk\nBatteries"), ("Costco", "Groceries\nCoffee"), ("Starbucks", "Pick up coffee"), ("Philz Coffee", "Buy coffee beans"), ("Library", "Return library books"), ("Grocery store", "Bread\nEggs")]
var searches = [MKLocalSearch]()
var receipts = [[String: Any]]()
var position = 0
func next() {
    guard position < cases.count else {
        let data = try! JSONSerialization.data(withJSONObject: ["checkedAt": ISO8601DateFormatter().string(from: Date()), "publicFixture": ["latitude": near.coordinate.latitude, "longitude": near.coordinate.longitude], "source": "Production NotePlaceIntent.infer/searchRequest/matches; live Apple Maps", "sensorAccess": false, "cases": receipts], options: [.prettyPrinted, .sortedKeys])
        FileHandle.standardOutput.write(data)
        exit(0)
    }
    let (title, text) = cases[position]; position += 1
    guard let intent = NotePlaceIntent.infer(title: title, text: text, details: NoteDetails()) else { fatalError("No intent for \(title)") }
    let search = MKLocalSearch(request: NotePlaceIntent.searchRequest(query: intent.query, near: near)); searches.append(search)
    search.start { response, error in
        guard error == nil, let response else { fatalError("Maps search failed for \(title): \(String(describing: error))") }
        let matched = response.mapItems.filter { intent.matches($0, near: near) }
        assert(!matched.isEmpty, "No actual nearby business/place resolved for \(title)")
        receipts.append(["title": title, "query": intent.query, "returned": response.mapItems.count, "matched": matched.count, "places": matched.map { item -> [String: Any] in
            let coordinate = item.location.coordinate
            return ["name": item.name ?? "", "category": item.pointOfInterestCategory?.rawValue ?? "", "latitude": coordinate.latitude, "longitude": coordinate.longitude]
        }])
        next()
    }
}
DispatchQueue.main.async { next() }
DispatchQueue.main.asyncAfter(deadline: .now() + 90) { fatalError("Maps lookup timed out") }
dispatchMain()
