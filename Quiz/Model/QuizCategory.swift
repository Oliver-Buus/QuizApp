struct CategoryResult: Decodable {
    let triviaCategories: [QuizCategory]
}

struct QuizCategory: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    var questionCount: QuestionCount?
    
    struct QuestionCount: Decodable, Hashable {
        let totalQuestionCount: Int
        let totalEasyQuestionCount: Int
        let totalMediumQuestionCount: Int
        let totalHardQuestionCount: Int
    }
    
}

struct QuestionCountResult: Decodable {
    let categoryId: Int
    let categoryQuestionCount: QuizCategory.QuestionCount
}
