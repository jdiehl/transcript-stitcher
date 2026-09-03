import AppKit
import Foundation

@MainActor
final class ClipboardMonitor {
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private var lastContent: String = ""
    private var onChange: (@Sendable (String) -> Void)?

    private let pollInterval: TimeInterval = 0.5

    func start(onChange: @escaping @Sendable (String) -> Void) {
        stop()
        self.onChange = onChange
        lastChangeCount = NSPasteboard.general.changeCount
        lastContent = ""

        let t = Timer(timeInterval: pollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.poll()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        onChange = nil
    }

    private func poll() {
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount

        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        guard let text = pasteboard.string(forType: .string) else { return }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard trimmed != lastContent else { return }

        lastContent = trimmed
        onChange?(trimmed)
    }
}
