import SwiftUI

struct AppCommands: Commands {
    let appState: AppState

    var body: some Commands {
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
                appState.copyTranscript()
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
            .disabled(!appState.hasContent)

            Button("Cut Transcript") {
                appState.cutTranscript()
            }
            .keyboardShortcut("x", modifiers: [.command, .shift])
            .disabled(!appState.hasContent)
        }
    }
}
