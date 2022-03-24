import Foundation
import SwiftSoup

enum fetchError: Error {
    case noToken, noData
}

class BackgroundManager {
    
    static let shared = BackgroundManager()
    
    let url = URL(string: "https://portals.veracross.com/cwa/student/student/overview")!
    
    func getGrades(filter: [String]?, completion: @escaping (Result<[Course], Error>)->()) -> URLSessionDataTask? {
        let query = [
            kSecAttrService: "session",
            kSecAttrAccount: "veracross",
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true,
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        guard let data = result as? Data else {
            completion(.failure(fetchError.noToken))
            return nil
        }
        let cookieHeaderField = ["Set-Cookie": "_veracross_session=\(String(data: data, encoding: .utf8)!)"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
        URLSession.shared.configuration.httpCookieStorage?.setCookies(cookies, for: url, mainDocumentURL: url)
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(fetchError.noData))
                return
            }
            completion(Result {
                let payload = String(data: data, encoding: .utf8)!
                let doc: Document = try! SwiftSoup.parse(payload)
                let courses: Elements = try! doc.select("ul.course-list.active").first()!.select("li")
                return courses.compactMap {course -> Course? in
                    let name = try! course.select("a.course-description").first()!
                    guard filter?.contains(try! name.text()) == true else {
                        return nil
                    }
                    
                    let letterGrade = try! course.select("span.course-letter-grade").first()!
                    
                    let updates = try! course.select("span.vx-badge.notification-badge").first()!
                    
                    return Course(name: try! name.text(), letter: try! letterGrade.text(), updates: Int(try! updates.text())!)
                }
            })
        }
        dataTask.resume()
        return dataTask
    }
}

struct Course {
    var name: String
    var letter: String
    var updates: Int
}
