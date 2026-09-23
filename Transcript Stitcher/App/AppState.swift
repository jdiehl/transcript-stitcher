import AppKit
import Foundation
import Observation

@Observable
@MainActor
final class AppState {
    private(set) var fragments: [Fragment] = []
    private(set) var assembledText: String = ""
    private(set) var chunks: [ChunkRange] = []
    private(set) var isMonitoring: Bool = false

    let undoManager = UndoManager()

    private let engine = StitchingEngine()
    private let monitor = ClipboardMonitor()

    private func registerUndo(_ actionName: String, action: @escaping (AppState) -> Void) {
        undoManager.setActionName(actionName)
        undoManager.registerUndo(withTarget: self) { target in
            action(target)
        }
    }

    init(fragments: [Fragment] = []) {
        self.fragments = fragments
        recomputeFromFragments()
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
        let fragment = Fragment(text: text)
        fragments.append(fragment)
        let result = engine.appendFragment(
            newFragment: text,
            fragmentIndex: fragments.count - 1,
            existingText: assembledText,
            existingChunks: chunks
        )
        assembledText = result.assembledText
        chunks = result.chunks

        registerUndo("Add Fragment") { $0.undoAddFragment() }
    }

    private func undoAddFragment() {
        guard let removed = fragments.popLast() else { return }
        recomputeFromFragments()

        registerUndo("Add Fragment") { $0.redoAddFragment(removed) }
    }

    private func redoAddFragment(_ fragment: Fragment) {
        fragments.append(fragment)
        let result = engine.appendFragment(
            newFragment: fragment.text,
            fragmentIndex: fragments.count - 1,
            existingText: assembledText,
            existingChunks: chunks
        )
        assembledText = result.assembledText
        chunks = result.chunks

        registerUndo("Add Fragment") { $0.undoAddFragment() }
    }

    private func recomputeFromFragments() {
        let result = engine.replay(fragments: fragments)
        assembledText = result.assembledText
        chunks = result.chunks
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
        let savedFragments = fragments
        fragments = []
        recomputeFromFragments()

        registerUndo("Clear") { $0.restoreFragments(savedFragments) }
    }

    private func restoreFragments(_ saved: [Fragment]) {
        fragments = saved
        recomputeFromFragments()

        registerUndo("Clear") { target in
            let current = target.fragments
            target.fragments = []
            target.recomputeFromFragments()
            target.registerUndo("Clear") { $0.restoreFragments(current) }
        }
    }

    func copyTranscript() throws {
        stopMonitoring()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        guard pasteboard.setString(assembledText, forType: .string) else {
            throw ClipboardError.writeFailed
        }
    }
  
    func cutTranscript() throws {
        try copyTranscript()
        clear()
    }
}
