import SwiftUI

struct QuizStartView: View {
    //@Environment(Controller.self) private var controller: Controller
    @EnvironmentObject var controller: Controller
    
    @State private var selectedCategory: QuizCategory? = nil
    
    @State private var selectedDifficulty: Difficulty = .any
    
    //@State private var isQuizStarted = false
    
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Category", selection: $selectedCategory) {
                    Text("Select a category").tag(nil as QuizCategory?)
                    ForEach(controller.categories) { category in
                        Text(category.name).tag(category)
                    }
                }
                
                if let selectedCategory = selectedCategory {
                    QuestionAmountView(category: selectedCategory)
                }
                
                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(Difficulty.allCases) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty)
                    }
                }
                .pickerStyle(.segmented)
                
                Button("Start Quiz") {
                    controller.loadQuestions(category: selectedCategory!, difficulty: selectedDifficulty) {
                        DispatchQueue.main.async {
                            controller.isQuizStarted = true
                            if let selectedCategory = selectedCategory {
                                controller.selectedCategory = selectedCategory
                            }
                        }

                    }
                }
                .font(.title)
                .fontWeight(.bold)
                .disabled(selectedCategory == nil)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color(.white))
                .background(Color(.blue))
                .cornerRadius(10)
                .padding()
                
            }
            .onAppear {
                if controller.isProgressing {
                    controller.isQuizStarted = true
                }
            }

            .navigationDestination(isPresented: $controller.isQuizStarted) {
                if let selectedCategory = selectedCategory {
                    QuizView(selectedCategory: selectedCategory, selectedDifficulty: selectedDifficulty)
                }
                else {
                    if let selectedCategory = controller.selectedCategory {
                        QuizView(selectedCategory: selectedCategory, selectedDifficulty: controller.selectedDifficulty)
                    }
                }
            }
            .navigationTitle("Start Quiz")
        }
    }
}

#Preview {
    QuizStartView()
        .environmentObject(Controller())
    
}
