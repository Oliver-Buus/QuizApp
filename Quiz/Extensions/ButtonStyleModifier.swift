import SwiftUI

struct ButtonStyleModifier: ViewModifier {
    let answer: String
    let selectedAnswer: String?
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.body)
            .fontWeight(.bold)
            .frame(width: 150, height: 75)
            .foregroundStyle(.white)
            .background(backgroundColor)
            .clipShape(Capsule())
            .shadow(
                color: .gray.opacity(0.75),
                radius: 5,
                x: 0,
                y: 2)
            .overlay(Capsule()
                .stroke(selectedAnswer == answer ? Color.black : Color.clear, lineWidth: 2))
    }
}

extension View {
    func buttonStyle(answer: String, selectedAnswer: String?, backgroundColor: Color = .gray) -> some View {
        return modifier(ButtonStyleModifier(answer: answer, selectedAnswer: selectedAnswer, backgroundColor: backgroundColor))
    }
}
