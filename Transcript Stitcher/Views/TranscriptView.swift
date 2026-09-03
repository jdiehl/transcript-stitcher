import SwiftUI

struct TranscriptView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if !appState.hasContent {
                ContentUnavailableView(
                    "No Transcript",
                    systemImage: "doc.text",
                    description: Text("Copy transcript fragments from Teams to begin assembling your transcript.")
                )
            } else {
                transcriptContent
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if appState.isMonitoring {
                    Button {
                        appState.stopMonitoring()
                    } label: {
                        Label("Stop", systemImage: "stop.circle.fill")
                            .foregroundStyle(.red)
                    }
                } else {
                    Button {
                        appState.startMonitoring()
                    } label: {
                        Label("Start", systemImage: "play.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    appState.copyTranscript()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .disabled(!appState.hasContent)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    appState.clear()
                } label: {
                    Label("Clear", systemImage: "trash")
                }
                .disabled(!appState.hasContent)
            }
        }
    }

    private var transcriptContent: some View {
        ScrollView {
            Text(appState.assembledText)
                .textSelection(.enabled)
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}

#Preview {
    TranscriptView()
        .environment(AppState())
}
