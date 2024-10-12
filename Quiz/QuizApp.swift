import SwiftUI

@main
struct QuizApp: App {
    @State var controller = Controller()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(controller)
        }
    }
}
