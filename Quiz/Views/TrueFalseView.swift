import SwiftUI

struct TrueFalseView: View {
    @Binding var selectedAnswer: String?
    
    var body: some View {
        HStack {
            Button("True") {
                selectedAnswer = "True"
            }
            .buttonStyle(answer: "True", selectedAnswer: selectedAnswer, backgroundColor: .green)

            
            Button("False") {
                selectedAnswer = "False"
            }
            .buttonStyle(answer: "False", selectedAnswer: selectedAnswer, backgroundColor: .red)
        }
    }
}

#Preview {
    TrueFalseView(selectedAnswer: .constant("True"))
}
