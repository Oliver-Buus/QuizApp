import SwiftUI

struct MultipleChoiceView: View {
    let options: [String]
    @Binding var selectedAnswer: String?
    
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<2) { index in
                    Button("\(options[index])") {
                        selectedAnswer = options[index]
                    }
                    .buttonStyle(answer: options[index], selectedAnswer: selectedAnswer)
                }
            }
            
            HStack {
                ForEach(2..<4) { index in
                    Button("\(options[index])") {
                        selectedAnswer = options[index]
                    }
                    .buttonStyle(answer: options[index], selectedAnswer: selectedAnswer)
                }
            }
        }
    }
}

#Preview {
    MultipleChoiceView(options: ["Option 1", "Option 2", "Option 3", "Option 4"], selectedAnswer: .constant("Option 2"))
}
