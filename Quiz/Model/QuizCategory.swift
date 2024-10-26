struct CategoryResult: Codable {
    let triviaCategories: [QuizCategory]
}

struct QuizCategory: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    var questionCount: QuestionCount?
    
    struct QuestionCount: Codable, Hashable {
        let totalQuestionCount: Int
        let totalEasyQuestionCount: Int
        let totalMediumQuestionCount: Int
        let totalHardQuestionCount: Int
    }
    
}

struct QuestionCountResult: Codable {
    let categoryId: Int
    let categoryQuestionCount: QuizCategory.QuestionCount
}
