import SwiftUI

struct QuestionAmountView: View {
    let category: QuizCategory
    
    var body: some View {
        VStack {
            if let questionCount = category.questionCount {
                Text("\(category.name)")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("Total questions: \(questionCount.totalQuestionCount)")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Easy:")
                            .fontWeight(.semibold) // Gør overskriften semibold
                        Spacer()
                        Text("\(questionCount.totalEasyQuestionCount)")
                    }
                    
                    HStack {
                        Text("Medium:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(questionCount.totalMediumQuestionCount)")
                    }
                    
                    HStack {
                        Text("Hard:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(questionCount.totalHardQuestionCount)")
                    }
                }
            }
        }
        .padding()
        .cornerRadius(10)
        
    }
}

#Preview {
    QuestionAmountView(
        category: QuizCategory(
            id: 0,
            name: "Common Knowledge",
            questionCount: QuizCategory.QuestionCount(
                totalQuestionCount: 100,
                totalEasyQuestionCount: 25,
                totalMediumQuestionCount: 50,
                totalHardQuestionCount: 25)))
}
