import Foundation

@Observable
class Controller {
    var categories: [QuizCategory] = []
    var questions: [Question] = []
    var token: String = ""
    
    
    init() {
        fetchSessionToken()
        guard let allCategoriesURL = URL(string: "https://opentdb.com/api_category.php") else { return }
        fetchCategories(from: allCategoriesURL) {
            Task {
                await self.fetchQuestionCount()
            }
        }
    }
    
    private func fetchSessionToken() {
        guard let url = URL(string: "https://opentdb.com/api_token.php?command=request") else { return }
        
        Task {
            guard let rawData = await NetworkService.getData(from: url) else { return }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let jsonResult = try decoder.decode(TokenResponse.self, from: rawData)
                
                if jsonResult.responseCode == 0 {
                    token = jsonResult.token
                    print("TOKEN: \(token)")
                }
            } catch {
                print("Failed to decode token response: ", error)
            }
            
            
        }
    }
    
    private func fetchCategories(from url: URL, completion: @escaping () -> Void) {
        Task {
            guard let rawData = await NetworkService.getData(from: url) else { return }
            self.categories = decodeCategories(from: rawData)
            //self.categories.append(QuizCategory(id: 0, name: "All Categories"))
            completion()
        }
    }
    
    private func fetchQuestionCount() async {
        var urls: [URL] = []
        categories.forEach { category in
            if category.id == 0 { return }
            if let url = URL(string: "https://opentdb.com/api_count.php?category=\(category.id)") {
                urls.append(url)
                print("Constructed URL: \(url)")
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
    
    
    func fetchQuestions(categoryString: String, difficulty: String, completion: @escaping () -> Void) {
        guard let category = categories.first(where: {categoryString == $0.name}) else { return }
        
        
        var urlComponents = URLComponents(string: "https://opentdb.com/api.php?amount=10")
        
        if category.id != 0 {
            let categoryItem = URLQueryItem(name: "category", value: "\(category.id)")
            urlComponents?.queryItems?.append(categoryItem)
        }
        if !difficulty.isEmpty {
            let difficultyItem = URLQueryItem(name: "difficulty", value: difficulty.lowercased())
            urlComponents?.queryItems?.append(difficultyItem)
        }
        
        guard let url = urlComponents?.url else { return }
        print(url)
        
        if !token.isEmpty {
            let tokenItem = URLQueryItem(name: "token", value: token)
            urlComponents?.queryItems?.append(tokenItem)
        }
        
        
        guard let url = urlComponents?.url else { return }
        print(url)
        
        Task(priority: .low) {
            guard let rawData = await NetworkService.getData(from: url) else { return }
            self.questions = decodeQuestions(from: rawData)
            completion()
        }
    }
    
    func decodeQuestions(from data: Data) -> [Question] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let jsonResult = try decoder.decode(QuestionResult.self, from: data)
            for question in self.questions {
                print(question.question)
            }
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
            categories = jsonResult.triviaCategories
            return categories
        } catch {
            print("decodeCategories error: ", error)
        }
        
        print("empty")
        return []
    }
}
