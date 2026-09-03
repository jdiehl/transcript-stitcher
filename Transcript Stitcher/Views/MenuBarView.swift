import SwiftUI

struct MenuBarView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Transcript Stitcher")
                .font(.headline)

            Divider()

            HStack {
                Text("Chunks:")
                Spacer()
                Text("\(appState.chunkCount)")
                    .monospacedDigit()
            }
            HStack {
                Text("Characters:")
                Spacer()
                Text("\(appState.assembledText.count)")
                    .monospacedDigit()
            }

            Divider()

            HStack(spacing: 12) {
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
                Spacer()
            }

            Divider()

            Button {
                appState.copyTranscript()
            } label: {
                Label("Copy Transcript", systemImage: "doc.on.doc")
            }
            .disabled(!appState.hasContent)

            Button {
                openWindow(id: "main-window")
            } label: {
                Label("Open Window", systemImage: "macwindow")
            }

            Button {
                appState.clear()
            } label: {
                Label("Clear", systemImage: "trash")
            }
            .disabled(!appState.hasContent)
        }
        .padding(12)
        .frame(width: 260)
    }
}

#Preview {
    MenuBarView()
        .environment(AppState())
}
