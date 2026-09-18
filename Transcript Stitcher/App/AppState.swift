import AppKit
import Foundation
import Observation

@Observable
@MainActor
final class AppState {
    private(set) var assembledText: String = ""
    private(set) var chunks: [ChunkRange] = []
    private(set) var isMonitoring: Bool = false

    private let service = StitchingService()
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
        Task {
            let result = await service.addFragment(text)
            assembledText = result.assembledText
            chunks = result.chunks
        }
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
        Task {
            await service.reset()
            assembledText = ""
            chunks = []
        }
    }

    func copyTranscript() {
        stopMonitoring()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(assembledText, forType: .string)
    }
}
