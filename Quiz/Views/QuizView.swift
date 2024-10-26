import SwiftUI

struct QuizView: View {
    //@Environment(Controller.self) private var controller: Controller
    
    var selectedCategory: QuizCategory
    
    @EnvironmentObject var controller: Controller
    
    @State private var questionIndex = 0
    @State private var selectedAnswer: String? = nil
    @State private var isAnswerCorrect: Bool = false
    @State private var showNextQuestionButton: Bool = false
    @State private var isLoadingMoreQuestions: Bool = false
    
    var body: some View {

        NavigationStack {
            VStack {
                if questionIndex >= controller.questions.count {
                    if isLoadingMoreQuestions {
                        ProgressView()
                    } else {
                        Text("Quiz Complete!")
                        
                        Button("Load More Questions") {
                            isLoadingMoreQuestions = true
                            controller.loadQuestions(category: selectedCategory, difficulty: .any) {
                                isLoadingMoreQuestions = false
                                questionIndex = 0
                            }
                        }
                    }
                } else {
                    let question = controller.questions[questionIndex]
                    let options = controller.shuffledAnswers[questionIndex]
                    Text(question.question)
                        .font(.title)
                        .padding()
                    
                    if question.type == QuestionType.multiple {
                        MultipleChoiceView(options: options, selectedAnswer: $selectedAnswer)
                    } else {
                        TrueFalseView(selectedAnswer: $selectedAnswer)
                    }
                    
                    Button("Confirm Answer") {
                        if let selectedAnswer = selectedAnswer {
                            isAnswerCorrect = selectedAnswer == question.correctAnswer
                            showNextQuestionButton = true
                        }
                    }
                    .disabled(selectedAnswer == nil)
                    .font(.body)
                    .fontWeight(.bold)
                    .frame(width: 150, height: 75)
                    .foregroundStyle(.white)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(
                        color: .gray.opacity(0.75),
                        radius: 5,
                        x: 0,
                        y: 2)
                    .padding()
                    
                    if showNextQuestionButton {
                        Text("\(isAnswerCorrect ? "Correct" : "Incorrect")")
                        Button("Next Question") {
                            questionIndex += 1
                            selectedAnswer = nil
                            showNextQuestionButton = false
                        }
                        .font(.body)
                        .fontWeight(.bold)
                        .frame(width: 150, height: 75)
                        .foregroundStyle(.white)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(
                            color: .gray.opacity(0.75),
                            radius: 5,
                            x: 0,
                            y: 2)
                        .padding()
                    }
                }
            }
            .navigationTitle("Quiz")
        }
    }
}

