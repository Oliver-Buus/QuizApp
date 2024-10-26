import Foundation

struct QuizProgress: Codable {
    let token: String
    let questions: [Question]
    let shuffledAnswers: [[String]]
    let category: QuizCategory
    let difficulty: Difficulty
    let questionsCompleted: Int
}
