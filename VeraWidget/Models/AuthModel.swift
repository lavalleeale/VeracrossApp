import Foundation
import Combine
import SwiftSoup
import WidgetKit

class AuthModel: ObservableObject {
    @Published var session: String?
    @Published var courses: [Course]?
    static let baseUrl = "https://portals.veracross.com"
    
    var cancellable = Set<AnyCancellable>()
    
    static let shared = AuthModel()
    
    init() {
        let query = [
            kSecAttrService: "session",
            kSecAttrAccount: "veracross",
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true,
            kSecAttrAccessGroup: "group.com.axlav.verawidget"
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        guard let data = result as? Data else {
            return
        }
        self.session = String(data: data, encoding: .utf8)
        let cookieHeaderField = ["Set-Cookie": "_veracross_session=\(self.session!)"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: URL(string: AuthModel.baseUrl)!)
        URLSession.shared.configuration.httpCookieStorage?.setCookies(cookies, for: URL(string: AuthModel.baseUrl)!, mainDocumentURL: URL(string: AuthModel.baseUrl)!)
        getCourses()
    }
    
    func makeRequest(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .sink(receiveCompletion: { print ("Received completion for \(url): \($0).") },
                  receiveValue: { data in
                completion(.success(data))
            }).store(in: &cancellable)
    }
    
    func getCourses() {
        let url = URL(string: "\(AuthModel.baseUrl)/cwa/student/student/overview")!
        makeRequest(url: url) { result in
            switch result {
            case .failure:
                return
            case .success(let data):
                let html = String(data: data, encoding: .utf8)!
                let doc: Document = try! SwiftSoup.parse(html)
                if (html.contains("forgot_password")) {
                    let query = [
                        kSecClass: kSecClassGenericPassword,
                        kSecAttrService: "session",
                        kSecAttrAccount: "veracross",
                        kSecAttrAccessGroup: "group.com.axlav.verawidget"
                    ] as CFDictionary
                    SecItemDelete(query)
                    DispatchQueue.main.async {
                        self.session = nil
                    }
                    return
                }
                let courses: Elements = try! doc.select("ul.course-list.active").first()!.select("li")
                let names = courses.compactMap {course -> Course? in
                    let letterGrade = try! course.select("span.course-letter-grade").first()
                    guard letterGrade != nil else {
                        return nil
                    }
                    let name = try! course.select("a.course-description").first()!
                    let idElement = try! course.select("a.course-list-grade-link").first()!
                    let link = try! idElement.attr("href")
                    let pattern = #"\/classes\/(.+)\/grade_detail"#
                    let regex = try! NSRegularExpression(pattern: pattern)
                    let stringRange = NSRange(location: 0, length: link.utf16.count)
                    let match = regex.firstMatch(in: link, options: [], range: stringRange)

                    return Course(name: try! name.text(), id: String(link[Range(match!.range(at: 1), in: link)!]))
                }
                DispatchQueue.main.async {
                    self.courses = names
                }
                UserDefaults(suiteName: "group.com.axlav.verawidget")!.set(names.map {$0.name}, forKey: "courses")
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    func saveToken(_ data: String, completion: @escaping (Error) -> Void) {
        
        // Create query
        let query = [
            kSecValueData: Data(data.utf8),
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "session",
            kSecAttrAccount: "veracross",
            kSecAttrAccessGroup: "group.com.axlav.verawidget"
        ] as CFDictionary
        
        // Add data in query to keychain
        let status = SecItemAdd(query, nil)
        
        if status != errSecSuccess {
            // Print out the error
            print("Error: \(status)")
        }
        
        self.session = data
        let cookie = HTTPCookie(properties: [
            .domain: ".veracross.com",
            .path: "/",
            .name: "_veracross_session",
            .value: data,
            .secure: "TRUE",
            .discard: "TRUE"
        ])
        HTTPCookieStorage.shared.setCookie(cookie!)
        getCourses()
    }
}

struct Course {
    var name: String
    var id: String
}
