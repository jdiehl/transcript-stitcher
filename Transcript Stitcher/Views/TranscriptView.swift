import SwiftUI

struct TranscriptView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var cache = AttributedTextCache()

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
                    try? appState.copyTranscript()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                        .foregroundStyle(.primary)
                }
                .disabled(!appState.hasContent)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    try? appState.cutTranscript()
                } label: {
                    Label("Cut", systemImage: "scissors")
                        .foregroundStyle(.primary)
                }
                .disabled(!appState.hasContent)
            }
        }
    }

    private var attributedText: AttributedString {
        cache.attributedText(
            text: appState.assembledText,
            chunks: appState.chunks,
            colorScheme: colorScheme
        )
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

private final class AttributedTextCache {
    private var cachedText: String?
    private var cachedChunks: [ChunkRange]?
    private var cachedColorScheme: ColorScheme?
    private var cachedResult: AttributedString?

    func attributedText(text: String, chunks: [ChunkRange], colorScheme: ColorScheme) -> AttributedString {
        if let cached = cachedResult,
           cachedText == text,
           cachedChunks == chunks,
           cachedColorScheme == colorScheme {
            return cached
        }

        var attributed = AttributedString(text)
        for chunk in chunks {
            guard chunk.length > 0 else { continue }
            let start = attributed.index(attributed.startIndex, offsetByCharacters: chunk.start)
            let end = attributed.index(attributed.startIndex, offsetByCharacters: chunk.start + chunk.length)
            attributed[start..<end].foregroundColor = ChunkColors.color(forColorIndex: chunk.id, colorScheme: colorScheme)
        }

        cachedText = text
        cachedChunks = chunks
        cachedColorScheme = colorScheme
        cachedResult = attributed

        return attributed
    }
}

#Preview {
    TranscriptView()
        .environment(AppState())
}
