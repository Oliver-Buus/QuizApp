

struct QuestionResult: Codable {
    let results: [Question]
}

struct Question: Codable {
    let type: QuestionType
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    var allAnswers: [String] {
           var answers = incorrectAnswers
           answers.append(correctAnswer)
        return answers.shuffled()
       }
}

enum QuestionType: String, Codable {
    case multiple
    case boolean
}
