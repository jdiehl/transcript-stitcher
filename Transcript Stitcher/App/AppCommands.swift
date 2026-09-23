import SwiftUI

struct AppCommands: Commands {
    let appState: AppState

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About Transcript Stitcher") {
                NSApp.orderFrontStandardAboutPanel(options: [
                    NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© 2026 Jonathan Diehl",
                    NSApplication.AboutPanelOptionKey(rawValue: "Credits"): NSAttributedString(
                        string: "https://github.com/jdiehl/transcript-stitcher",
                        attributes: [.link: URL(string: "https://github.com/jdiehl/transcript-stitcher")!]
                    )
                ])
            }
        }

        CommandGroup(replacing: .undoRedo) {
            Button("Undo") {
                appState.undoManager.undo()
            }
            .keyboardShortcut("z", modifiers: .command)
            .disabled(!appState.undoManager.canUndo)

            Button("Redo") {
                appState.undoManager.redo()
            }
            .keyboardShortcut("z", modifiers: [.command, .shift])
            .disabled(!appState.undoManager.canRedo)
        }

        CommandMenu("Transcript") {
            Button("Start/Stop") {
                appState.toggleMonitoring()
            }
            .keyboardShortcut("r", modifiers: .command)
            
            Divider()
            
            Button("Copy Transcript") {
                try? appState.copyTranscript()
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
            .disabled(!appState.hasContent)

            Button("Cut Transcript") {
                try? appState.cutTranscript()
            }
            .keyboardShortcut("x", modifiers: [.command, .shift])
            .disabled(!appState.hasContent)
        }
    }
}
