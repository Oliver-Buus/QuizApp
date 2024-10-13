import SwiftUI

@main
struct QuizApp: App {
    @StateObject var controller = Controller()
    var body: some Scene {
        WindowGroup {
            QuizStartView()
                .environmentObject(controller)
        }
    }
}
