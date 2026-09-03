import SwiftUI

@main
struct TranscriptStitcherApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        Window("Transcript Stitcher", id: "main-window") {
            MainWindow()
                .environment(appState)
        }
        .defaultPosition(.center)
        .defaultSize(width: 700, height: 500)
        .commands {
            CommandMenu("Transcript") {
                Button("Copy Transcript") {
                    appState.copyTranscript()
                }
                .keyboardShortcut("c", modifiers: .command)
                .disabled(!appState.hasContent)

                Button("Start/Stop") {
                    appState.toggleMonitoring()
                }
                .keyboardShortcut("r", modifiers: .command)

                Button("Clear") {
                    appState.clear()
                }
                .keyboardShortcut("x", modifiers: .command)
            }
        }

        MenuBarExtra("Transcript Stitcher", systemImage: "doc.on.clipboard") {
            MenuBarView()
                .environment(appState)
        }
        .menuBarExtraStyle(.window)
    }
}
