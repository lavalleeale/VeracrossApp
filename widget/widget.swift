import WidgetKit
import SwiftUI
import Intents
import SwiftSoup

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> CoursesEntry {
        CoursesEntry(date: Date(), configuration: SelectCoursesIntent())
    }
    
    func getSnapshot(for configuration: SelectCoursesIntent, in context: Context, completion: @escaping (CoursesEntry) -> ()) {
        let entry = CoursesEntry(date: Date(), configuration: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: SelectCoursesIntent, in context: Context, completion: @escaping (Timeline<CoursesEntry>) -> ()) {
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        _ = BackgroundManager.shared.getGrades(filter: configuration.Courses) { result in
            switch result {
            case .failure(let error):
                completion(Timeline(entries: [CoursesEntry(date: Date(), configuration: SelectCoursesIntent(), error: error.localizedDescription)], policy: .atEnd))
                break
            case .success(let response):
                completion(Timeline(entries: [CoursesEntry(date: Date(), courses: response, configuration: SelectCoursesIntent())], policy: .after(Date().addingTimeInterval(30*60))))
                break
            }
            
        }
    }
}

struct CoursesEntry: TimelineEntry {
    var date: Date
    
    var courses: [Course]?
    
    let configuration: SelectCoursesIntent
    
    var error: String?
}

@main
struct widget: Widget {
    let kind: String = "com.axlav.VeraWidget.widget"
    let backgroundData = BackgroundManager.shared
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectCoursesIntent.self, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct widget_Previews: PreviewProvider {
    static var previews: some View {
        widgetEntryView(entry: CoursesEntry(date: Date(), configuration: SelectCoursesIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
