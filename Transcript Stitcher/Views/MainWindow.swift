import SwiftUI

struct MainWindow: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 0) {
            MonitoringStatusBar(isMonitoring: appState.isMonitoring)
            TranscriptView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 400, idealWidth: 600, minHeight: 350, idealHeight: 400)
        .onChange(of: appState.fragments) { _, newFragments in
            if let data = try? JSONEncoder().encode(newFragments) {
                UserDefaults.standard.set(data, forKey: "fragments")
            }
        }
    }
}

#Preview {
    MainWindow()
        .environment(AppState())
}
