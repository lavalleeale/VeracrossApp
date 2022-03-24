import Foundation
import SwiftSoup

class ClassGradesModel: ObservableObject {
    let course: Course
    @Published var failure = false
    @Published var grade: Grade?
    @Published var calc: [[String]]?
    @Published var names: [String]?
    
    init(course: Course) {
        self.course = course
        getAssignments()
    }
    
    func getAssignments() {
        AuthModel.shared.makeRequest(url: URL(string: "https://documents.veracross.com/cwa/grade_detail/\(course.id)")!) { result in
            switch result {
            case .failure:
                self.failure = true
                return
            case .success(let data):
                let html = String(data: data, encoding: .utf8)!
                let doc: Document = try! SwiftSoup.parse(html)
                let gradeDetails = try! doc.select("div.overall_grade")
                let number = Double(try! (try! gradeDetails.select("span.ptd_grade")).text())!
                let letter = try! (try! gradeDetails.select("span.letter_grade")).text()
                let overview = try! doc.select("div#overall_grade_calculation")
                let numerator = try! overview.select("div.numerator").first()
                let denominator = try! overview.select("div.denominator").first()
                let names = try! doc.select("td > strong")
                DispatchQueue.main.async {
                    self.names = names.map {try! $0.text()}
                    self.grade = Grade(letter: letter, number: number)
                    if (numerator != nil && denominator != nil) {
                        self.calc = [
                            try! numerator!.select("span").map {try! $0.text()},
                            try! denominator!.select("span").map {try! $0.text()}
                        ]
                    } else {
                        self.calc = [try! overview.select("span").map {try! $0.text()}]
                    }
                }
                break
            }
        }
    }
    func formatNames(index: Int, parens: Bool = true) -> String {
        return self.calc![index].enumerated().map {"\(self.names![$0]) \(parens ? "(": "")\($1)\(parens ? ")": "")"}
            .joined(separator: " + ")
    }
}

struct Grade {
    var letter: String
    var number: Double
}
