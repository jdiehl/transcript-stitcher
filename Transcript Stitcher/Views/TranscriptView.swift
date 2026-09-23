import SwiftUI

struct TranscriptView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

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
                    appState.cutTranscript()
                } label: {
                    Label("Cut", systemImage: "scissors")
                        .foregroundStyle(.primary)
                }
                .disabled(!appState.hasContent)
            }
        }
    }

    private var attributedText: AttributedString {
        var attributed = AttributedString(appState.assembledText)
        for chunk in appState.chunks {
            guard chunk.length > 0 else { continue }
            let start = attributed.index(attributed.startIndex, offsetByCharacters: chunk.start)
            let end = attributed.index(attributed.startIndex, offsetByCharacters: chunk.start + chunk.length)
            attributed[start..<end].foregroundColor = ChunkColors.color(forColorIndex: chunk.id, colorScheme: colorScheme)
        }
        return attributed
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
                    Text(attributedText)
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
