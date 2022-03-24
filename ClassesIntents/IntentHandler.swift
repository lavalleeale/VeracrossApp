import Intents

class IntentHandler: INExtension, SelectCoursesIntentHandling {
    func provideCoursesOptionsCollection(for intent: SelectCoursesIntent, with completion: @escaping (INObjectCollection<NSString>?, Error?) -> Void) {
        
        let courses = UserDefaults(suiteName: "group.com.axlav.verawidget")!.stringArray(forKey: "courses")!
        let collection = INObjectCollection(items: courses as [NSString])

        // Call the completion handler, passing the collection.
        completion(collection, nil)
    }
}
