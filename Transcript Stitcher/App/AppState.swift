import AppKit
import Foundation
import Observation

@Observable
@MainActor
final class AppState {
    private(set) var assembledText: String = ""
    private(set) var chunks: [ChunkRange] = []
    private(set) var isMonitoring: Bool = false

    private let engine = StitchingEngine()
    private let monitor = ClipboardMonitor()

    init() {
        startMonitoring()
    }

    var hasContent: Bool { !assembledText.isEmpty }

    func startMonitoring() {
        monitor.start { [weak self] text in
            Task { @MainActor in
                self?.addFragment(text)
            }
        }
        isMonitoring = true
    }

    func stopMonitoring() {
        monitor.stop()
        isMonitoring = false
    }

    func addFragment(_ text: String) {
        let stitch = engine.stitch(newFragment: text, existingText: assembledText)
        guard stitch.newChunkLength > 0 else { return }

        assembledText = stitch.assembledText
        chunks = engine.updateChunks(
            existing: chunks,
            chunkLength: stitch.newChunkLength,
            textLength: assembledText.count
        )
        let nextId = (chunks.map(\.id).max() ?? -1) + 1
        let chunkStart = assembledText.count - stitch.newChunkLength
        chunks.append(ChunkRange(id: nextId, start: chunkStart, length: stitch.newChunkLength))
    }

    func toggleMonitoring() {
        if isMonitoring {
            stopMonitoring()
        } else {
            startMonitoring()
        }
    }

    func clear() {
        stopMonitoring()
        assembledText = ""
        chunks = []
    }

    func copyTranscript() {
        stopMonitoring()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(assembledText, forType: .string)
    }
}
