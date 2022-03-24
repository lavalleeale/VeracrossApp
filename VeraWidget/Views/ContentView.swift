import SwiftUI

struct ContentView: View {
    @State var showLogin = false
    @ObservedObject var authModel = AuthModel.shared
    
    var body: some View {
        TabView() {
            if (authModel.courses != nil) {
                AssignmentsView()
                    .tabItem {
                        Label("Assignments", systemImage: "list.bullet")
                    }
                UpcomingView()
                    .tabItem {
                        Label("Upcoming", systemImage: "checklist")
                        
                    }
                GradesView()
                    .tabItem {
                        Label("Grades", systemImage: "textformat.abc")
                    }
            } else {
                LoginView()
                    .tabItem {
                        Label("Login", systemImage: "person.crop.circle")
                    }
            }
        }
        .environmentObject(authModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
