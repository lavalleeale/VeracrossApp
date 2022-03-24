import SwiftUI

struct GradesView: View {
    @EnvironmentObject var authModel: AuthModel
    
    var body: some View {
        NavigationView {
            List(authModel.courses!, id: \.id) { course in
                NavigationLink(course.name) {
                    ClassGradesView(course: course)
                        .navigationTitle("Grades for \(course.name)")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .navigationTitle("All Grades")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GradesView_Previews: PreviewProvider {
    static var previews: some View {
        GradesView()
    }
}
