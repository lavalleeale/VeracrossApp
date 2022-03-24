import SwiftUI

struct ClassAssignmentsView: View {
    @ObservedObject var classAssignmentsModel: ClassAssignmentsModel
    
    init(course: Course) {
        classAssignmentsModel = ClassAssignmentsModel(course: course)
    }
    
    var body: some View {
        if (classAssignmentsModel.assignments != nil) {
            List {
                ForEach(CompletionStatus.allCases, id:\.self) { status in
                    if (classAssignmentsModel.assignments!.filter {$0.completionStatus == status}.count != 0) {
                        Section(status.name()) {
                            ForEach(classAssignmentsModel.assignments!.filter {$0.completionStatus == status}) { work in
                                AssignmentListRow(work: work)
                            }
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
        } else {
            ProgressView()
        }
    }
}

struct AssignmentListRow: View {
    @State var work: Assignment
    
    var body: some View {
        NavigationLink {
            Text(work.assignmentNotes ?? "No Extra Info")
        } label: {
            HStack {
                Text(work.assignmentDescription)
                Spacer()
                if (work.completionStatus == .complete || work.completionStatus == .pending) {
                    Text("\(work.rawScore == "" ? "?" : work.rawScore) / \(work.maximumScore)")
                }
            }
            .lineLimit(1)
        }
    }
}
