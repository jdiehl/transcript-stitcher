import SwiftUI

struct MainWindow: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 0) {
            MonitoringStatusBar(isMonitoring: appState.isMonitoring)
            TranscriptView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

#Preview {
    MainWindow()
        .environment(AppState())
}
