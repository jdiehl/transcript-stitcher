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
        let fragment = Fragment(text: text)
        fragments.append(fragment)
        recomputeFromFragments()

        undoManager.setActionName("Add Fragment")
        undoManager.registerUndo(withTarget: self) { target in
            target.undoAddFragment()
        }
    }

    private func undoAddFragment() {
        guard let removed = fragments.popLast() else { return }
        recomputeFromFragments()

        undoManager.setActionName("Add Fragment")
        undoManager.registerUndo(withTarget: self) { target in
            target.redoAddFragment(removed)
        }
    }

    private func redoAddFragment(_ fragment: Fragment) {
        fragments.append(fragment)
        recomputeFromFragments()

        undoManager.setActionName("Add Fragment")
        undoManager.registerUndo(withTarget: self) { target in
            target.undoAddFragment()
        }
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

        undoManager.setActionName("Clear")
        undoManager.registerUndo(withTarget: self) { target in
            target.restoreFragments(savedFragments)
        }
    }

    private func restoreFragments(_ saved: [Fragment]) {
        fragments = saved
        recomputeFromFragments()

        undoManager.setActionName("Clear")
        undoManager.registerUndo(withTarget: self) { target in
            let current = target.fragments
            target.fragments = []
            target.recomputeFromFragments()
            target.undoManager.registerUndo(withTarget: target) { innerTarget in
                innerTarget.restoreFragments(current)
            }
        }
    }

    func copyTranscript() {
        stopMonitoring()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(assembledText, forType: .string)
    }
}
