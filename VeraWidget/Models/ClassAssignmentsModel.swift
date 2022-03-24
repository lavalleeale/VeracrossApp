import Foundation
import SwiftSoup

class ClassAssignmentsModel: ObservableObject {
    let course: Course
    @Published var failure = false
    @Published var assignments: [Assignment]?
    
    init(course: Course) {
        self.course = course
        getAssignments()
    }
    
    func getAssignments() {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMdYY")
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        AuthModel.shared.makeRequest(url: URL(string: "https://portals-embed.veracross.com/cwa/student/enrollment/\(course.id)/assignments")!) { result in
            switch result {
            case .failure:
                self.failure = true
                return
            case .success(let data):
                self.assignments =  try! decoder.decode(AssignmentsData.self, from: data).assignments
                break
            }
        }
    }
}

struct AssignmentsData: Decodable {
    var assignments: [Assignment]
}

struct Assignment: Decodable, Identifiable {
    var assignmentType: String
    var assignmentDescription: String
    var assignmentNotes: String?
    var date: Date
    var maximumScore: Int
    var rawScore: String
    var completionStatus: CompletionStatus
    var id: Int
    
    private enum CodingKeys : String, CodingKey {
        case assignmentType = "assignment_type", assignmentDescription = "assignment_description", assignmentNotes = "assignment_notes", date = "_date", maximumScore = "maximum_score", rawScore = "raw_score", completionStatus = "completion_status", id
    }
}

enum CompletionStatus: String, Decodable, CaseIterable {
    case incomplete = "Incomplete",
         pending = "Pending",
         complete = "Complete",
         late = "Late",
         notRequired = "NREQ",
         notGraded = "Turned In/Not Graded"
    public func name() -> String {
        switch self {
        case .pending:
            return "Pending"
        case .notRequired:
            return "Not Required"
        case .complete:
            return "Complete"
        case .incomplete:
            return "Incomplete"
        case .late:
            return "Late"
        case .notGraded:
            return "Not Graded"
        }
      }
}
