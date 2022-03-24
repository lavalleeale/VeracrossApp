import SwiftUI

struct UpcomingView: View {
    @ObservedObject var upcomingModel = UpcomingModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if (upcomingModel.events != nil) {
                    List {
                        ForEach(upcomingModel.dates!, id: \.self) { date in
                            Section(Calendar.current.isDateInToday(date) ? "Today" : Calendar.current.isDateInTomorrow(date) ? "Tomorrow" : "In \(Calendar.current.dateComponents([.day], from: Date(), to: date).day! + 1) days") {
                                ForEach(upcomingModel.events!.filter {$0.date == date}) { event in
                                    Text(event.tooltip)
                                }
                            }
                        }
                    }
                    .listStyle(SidebarListStyle())
                } else {
                    ProgressView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Upcomming Assignments")
        }
    }
}

struct UpcomingView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingView()
    }
}
