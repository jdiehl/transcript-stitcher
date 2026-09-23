import SwiftUI

@main
struct TranscriptStitcherApp: App {
    @State private var appState: AppState

    init() {
        let restoredFragments: [Fragment] = {
            guard let data = UserDefaults.standard.data(forKey: "fragments"),
                  let fragments = try? JSONDecoder().decode([Fragment].self, from: data) else {
                return []
            }
            return fragments
        }()
        _appState = State(initialValue: AppState(fragments: restoredFragments))
    }

    var body: some Scene {
        Window("Transcript Stitcher", id: "main-window") {
            MainWindow()
                .environment(appState)
        }
        .defaultPosition(.center)
        .defaultSize(width: 700, height: 500)
        .commands {
            AppCommands(appState: appState)
        }
    }
}
