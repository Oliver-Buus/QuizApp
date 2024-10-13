

struct QuestionResult: Decodable {
    let results: [Question]
}

struct Question: Decodable {
    let type: QuestionType
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    var allAnswers: [String] {
           var answers = incorrectAnswers
           answers.append(correctAnswer)
           return answers
       }
}

enum QuestionType: String, Decodable {
    case multiple
    case boolean
}
