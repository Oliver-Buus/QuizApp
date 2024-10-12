import SwiftUI

struct CheckAnswerView: View {
    let isAnswerCorrect: Bool
    
    var body: some View {
        Text("Your answer is \(isAnswerCorrect ? "correct" : "incorrect")")
            .font(.largeTitle)
        Button("Go to next question") {
            
        }
    }
}

#Preview {
    CheckAnswerView(isAnswerCorrect: false)
}
