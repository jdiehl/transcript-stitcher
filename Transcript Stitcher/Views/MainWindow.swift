import SwiftUI

struct MainWindow: View {
    var body: some View {
        TranscriptView()
            .frame(minWidth: 600, minHeight: 400)
    }
}

#Preview {
    MainWindow()
        .environment(AppState())
}
