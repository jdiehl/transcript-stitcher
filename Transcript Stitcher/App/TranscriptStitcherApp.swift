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
                Button("Start/Stop") {
                    appState.toggleMonitoring()
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Divider()
                
                Button("Copy Transcript") {
                    appState.copyTranscript()
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .disabled(!appState.hasContent)

                Button("Cut Transcript") {
                    appState.copyTranscript()
                    appState.clear()
                }
                .keyboardShortcut("x", modifiers: [.command, .shift])
                .disabled(!appState.hasContent)
            }
        }
    }
}
