import SwiftUI

struct widgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
            if ((entry.error) != nil) {
                Text(entry.error!)
            } else if (entry.courses != nil && entry.courses!.count > 0) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Name")
                        ForEach(entry.courses!, id: \.name) { course in
                                Text(course.name)
                                .lineLimit(1)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("Grade")
                        ForEach(entry.courses!, id: \.name) { course in
                            Text(course.letter).foregroundColor(course.updates != 0 ? Color.orange : Color.primary)
                        }
                    }
                }
            } else {
                Text("Select Courses")
            }
        }
    }
}
