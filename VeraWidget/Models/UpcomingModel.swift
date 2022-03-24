import Foundation
import SwiftSoup

class UpcomingModel: ObservableObject {
    @Published var failure = false
    @Published var events: [Event]?
    @Published var dates: [Date]?
    
    init() {
        getAssignments()
    }
    
    func getAssignments() {
        let decoder = JSONDecoder()
        let jsonDateFormatter = DateFormatter()
        jsonDateFormatter.setLocalizedDateFormatFromTemplate("MMdyy")
        decoder.dateDecodingStrategy = .formatted(jsonDateFormatter)
        let urlDateFormatter = DateFormatter()
        urlDateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: 5, to: start)!
        AuthModel.shared.makeRequest(url: URL(string: "https://portals.veracross.com/cwa/student/component/MyEventsStudent/1306/load_data?start_date=\(urlDateFormatter.string(from: start))&end_date=\(urlDateFormatter.string(from: end))")!) { result in
            switch result {
            case .failure:
                self.failure = true
                return
            case .success(let data):
                DispatchQueue.main.async {
                    let events = try! decoder.decode(EventsData.self, from: data).events.filter {$0.recordType == 3}
                    var seen = Set<Date>()
                    self.dates = events.map {$0.date}.filter {seen.insert($0).inserted}
                    self.events = events
                }
                break
            }
        }
    }
}

struct EventsData: Decodable {
    var events: [Event]
}

struct Event: Decodable, Identifiable {
    var recordType: Int
    var date: Date
    var id: String
    var tooltip: String
    var description: String
    
    private enum CodingKeys : String, CodingKey {
        case recordType = "record_type",
             id,
             tooltip,
             description,
             date = "start_date"
    }
}
