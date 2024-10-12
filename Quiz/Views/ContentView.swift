import SwiftUI

struct ContentView: View {
    var body: some View {
        QuizStartView()
    }
}

#Preview {
    ContentView()
        .environment(Controller())
}
