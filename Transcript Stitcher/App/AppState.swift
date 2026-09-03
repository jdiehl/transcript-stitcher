import AppKit
import Foundation
import Observation

@Observable
@MainActor
final class AppState {
    private(set) var assembledText: String = ""
    private(set) var chunkCount: Int = 0
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
                self?.addChunk(text)
            }
        }
        isMonitoring = true
    }

    func stopMonitoring() {
        monitor.stop()
        isMonitoring = false
    }

    func addChunk(_ text: String) {
        let result = engine.stitch(newChunk: text, existingText: assembledText)
        assembledText = result.assembledText
        chunkCount += 1
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
        chunkCount = 0
    }

    func copyTranscript() {
        stopMonitoring()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(assembledText, forType: .string)
    }
}
