import SwiftUI

struct TranscriptView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        transcriptContent
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
                        .foregroundStyle(.primary)
                }
                .disabled(!appState.hasContent)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    appState.copyTranscript()
                    appState.clear()
                } label: {
                    Label("Cut", systemImage: "scissors")
                        .foregroundStyle(.primary)
                }
                .keyboardShortcut("x", modifiers: [.command, .shift])
                .disabled(!appState.hasContent)
            }
        }
    }

    private var transcriptContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if !appState.hasContent {
                    ContentUnavailableView(
                        "No Transcript",
                        systemImage: "doc.text",
                        description: Text("Copy transcript fragments to begin assembling your transcript.")
                    )
                    .frame(maxWidth: .infinity, minHeight: 300)
                } else {
                    Text(appState.assembledText)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
            }
            .onChange(of: appState.assembledText) {
                withAnimation {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
}

#Preview {
    TranscriptView()
        .environment(AppState())
}
