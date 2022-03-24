import SwiftUI

struct ClassGradesView: View {
    @ObservedObject var classGradesModel: ClassGradesModel
    
    init(course: Course) {
        classGradesModel = ClassGradesModel(course: course)
    }
    
    var body: some View {
        if (classGradesModel.grade != nil) {
            VStack {
                Text("\(classGradesModel.grade!.letter) | \(String(classGradesModel.grade!.number))")
                if (classGradesModel.calc!.count != 1) {
                    Text(classGradesModel.formatNames(index: 0))
                    Divider()
                    Text(classGradesModel.formatNames(index: 1))
                } else {
                    Text(classGradesModel.formatNames(index: 0, parens: false))
                }
                Spacer()
            }
        }
    }
}
