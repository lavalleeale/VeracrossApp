import SwiftUI

struct AssignmentsView: View {
    @EnvironmentObject var authModel: AuthModel
    
    var body: some View {
        NavigationView {
            List(authModel.courses!, id: \.id) { course in
                NavigationLink(course.name) {
                    ClassAssignmentsView(course: course)
                        .navigationTitle("Assignments for \(course.name)")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .navigationTitle("All Assignments")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AssignmentsView_Previews: PreviewProvider {
    static var previews: some View {
        AssignmentsView()
    }
}
