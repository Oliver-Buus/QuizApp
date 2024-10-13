
enum Difficulty: String, CaseIterable, Identifiable {
    case any = "Any"
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    var id: String { self.rawValue }
}
