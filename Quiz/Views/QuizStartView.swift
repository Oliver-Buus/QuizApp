import SwiftUI

struct QuizStartView: View {
    @Environment(Controller.self) private var controller: Controller
    
    @State private var selectedCategory: QuizCategory? = nil
    
    @State private var selectedDifficulty = ""
    
    @State private var isQuizStarted = false
    
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Category", selection: $selectedCategory) {
                    Text("Select a category").tag(nil as QuizCategory?)
                    ForEach(controller.categories) { category in
                        Text(category.name).tag(category)
                    }
                }
                .onChange(of: selectedCategory) {
                    selectedDifficulty = ""
                }
                
                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(Difficulty.allCases) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty)
                    }
                }
                .pickerStyle(.segmented)
                
                if let selectedCategory = selectedCategory,
                   let questionCount = selectedCategory.questionCount {
                    VStack {
                        
                        Text("\(selectedCategory.name)")
                            .font(.title2)
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
                    .padding()
                    .cornerRadius(10)
                }
                
                
                Button("Start Quiz") {
                    controller.fetchQuestions(categoryString: selectedCategory?.name ?? "", difficulty: selectedDifficulty) {
                        isQuizStarted = true
                    }
                }
                .disabled(selectedCategory == nil)
            }
            .navigationDestination(isPresented: $isQuizStarted) {
                QuizView()
            }
            .navigationTitle("Start Quiz")
        }
    }
}

#Preview {
    QuizStartView()
        .environment(Controller())
    
}
