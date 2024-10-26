import Foundation

//@Observable
class Controller: ObservableObject {
    @Published var categories: [QuizCategory] = []
    var questions: [Question] = []
    var shuffledAnswers: [[String]] = [] // used to keep all answers
    var token: String = ""
    var isProgressing: Bool = false
    var selectedCategory: QuizCategory? = nil
    var selectedDifficulty: Difficulty = .any
    var questionsCompleted: Int = 0
    @Published var isQuizStarted: Bool = false
    
    init() {
        let fileName = "quizProgress.json"
        let progress = readFile(fileName: fileName)
        if let progress {
            self.questions = progress.questions
            self.shuffledAnswers = progress.shuffledAnswers
            self.token = progress.token
            self.selectedCategory = progress.category
            self.selectedDifficulty = progress.difficulty
            self.questionsCompleted = progress.questionsCompleted
            self.isQuizStarted = true
            isProgressing = true
        }

        if !isProgressing {
            requestSessionToken()
        }
        guard let allCategoriesURL = URL(string: "https://opentdb.com/api_category.php") else { return }
        loadQuizCategories(from: allCategoriesURL)
    }
        
    /// Requests the server for a new token
    private func requestSessionToken() {
        guard let url = URL(string: "https://opentdb.com/api_token.php?command=request") else { return }
        
        Task {
            guard let rawData = await NetworkService.getData(from: url) else { return }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let jsonResult = try decoder.decode(TokenResponse.self, from: rawData)
                
                if jsonResult.responseCode == 0 {
                    token = jsonResult.token
                }
            } catch {
                print("Failed to decode token response: ", error)
            }
        }
    }
    
    /// Loads all the quiz categories from the server
    private func loadQuizCategories(from url: URL) {
        Task { @MainActor in
            guard let rawData = await NetworkService.getData(from: url) else { return }
            self.categories.append(contentsOf: decodeCategories(from: rawData))
            await loadQuestionCountsForCategories()
            addAnyCategoryWithQuestionCounts()
        }
    }
    
    /// Loads the amount of questions for each category
    @MainActor
    private func loadQuestionCountsForCategories() async {
        var urls: [URL] = []
        categories.forEach { category in
            if category.id == 0 { return }
            if let url = URL(string: "https://opentdb.com/api_count.php?category=\(category.id)") {
                urls.append(url)
            }
        }
        
        for url in urls {
            guard let data = await NetworkService.getData(from: url) else { continue }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let jsonResult = try decoder.decode(QuestionCountResult.self, from: data)
                if let index = categories.firstIndex(where: { $0.id == jsonResult.categoryId }) {
                    categories[index].questionCount = jsonResult.categoryQuestionCount
                }
            } catch {
                print("decodeQuestions error: ", error)
            }
        }
    }
    
    /// Loads 10 questions based on the chosen category and difficulty
    func loadQuestions(category: QuizCategory, difficulty: Difficulty, completion: @escaping () -> Void) {        
        
        var urlComponents = URLComponents(string: "https://opentdb.com/api.php?amount=10")
        
        if category.id != 0 {
            let categoryItem = URLQueryItem(name: "category", value: "\(category.id)")
            urlComponents?.queryItems?.append(categoryItem)
        }
        if difficulty != .any {
            let difficultyItem = URLQueryItem(name: "difficulty", value: difficulty.rawValue.lowercased())
            urlComponents?.queryItems?.append(difficultyItem)
        }
                
        if !token.isEmpty {
            let tokenItem = URLQueryItem(name: "token", value: token)
            urlComponents?.queryItems?.append(tokenItem)
        }
        
        
        guard let url = urlComponents?.url else { return }
        
        Task(priority: .low) {
            guard let rawData = await NetworkService.getData(from: url) else { return }
            self.questions = decodeQuestions(from: rawData)
            self.shuffledAnswers = self.questions.map {$0.allAnswers} // Puts all answers in the matrix
            completion()
        }
    }
    
    func decodeQuestions(from data: Data) -> [Question] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let jsonResult = try decoder.decode(QuestionResult.self, from: data)
            return jsonResult.results
        } catch {
            print("decodeQuestions error: ", error)
        }
        print("empty")
        return []
    }
    
    func decodeCategories(from data: Data) -> [QuizCategory] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let jsonResult = try decoder.decode(CategoryResult.self, from: data)
            return jsonResult.triviaCategories
        } catch {
            print("decodeCategories error: ", error)
        }
        return []
    }
    
    /// Creates a category named "Any" that contains the total number of questions
    private func addAnyCategoryWithQuestionCounts() {
        var easyQuestions = 0
        var mediumQuestions = 0
        var hardQuestions = 0
        
        categories.forEach { category in
            easyQuestions += category.questionCount?.totalEasyQuestionCount ?? 0
            mediumQuestions += category.questionCount?.totalMediumQuestionCount ?? 0
            hardQuestions += category.questionCount?.totalHardQuestionCount ?? 0
        }
        let totalAmount = easyQuestions + mediumQuestions + hardQuestions
        
        categories
            .insert(
                QuizCategory(
                    id: 0,
                    name: "Any",
                    questionCount: QuizCategory.QuestionCount(
                        totalQuestionCount: totalAmount,
                        totalEasyQuestionCount: easyQuestions,
                        totalMediumQuestionCount: mediumQuestions,
                        totalHardQuestionCount: hardQuestions)
                ),
                at: 0)
    }
    
    func readFile(fileName: String) -> QuizProgress? {
        guard let fileURL = getFileURL(fileName: fileName) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(QuizProgress.self, from: data)
        } catch {
            print("Error reading file at \(fileURL): \(error)")
        }
        return nil
    }
    
    
    func writeFile(_ progress: QuizProgress, toJson file: String) {
        guard let path = getFileURL(fileName: file) else { return }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(progress)
            try data.write(to: path)
        } catch {
            print("Error writing to file \(path): \(error)")
        }
    }
    
    func deleteFile(fileName: String) {
        guard let fileURL = getFileURL(fileName: fileName) else { return  }
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error deleting quiz progress file at \(fileURL): \(error)")
        }
    }
    
    func getFileURL(fileName: String) -> URL? {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentDirectory?.appendingPathComponent(fileName)
    }
    

    
    
}
