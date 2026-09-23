import AppKit
import Foundation

enum ClipboardError: Error, LocalizedError {
    case readFailed
    case writeFailed

    var errorDescription: String? {
        switch self {
        case .readFailed: return "Unable to read from the clipboard."
        case .writeFailed: return "Unable to write to the clipboard."
        }
    }
}

@MainActor
final class ClipboardMonitor {
    private var timer: DispatchSourceTimer?
    private var lastChangeCount: Int = 0
    private var lastContent: String = ""
    private var onChange: (@Sendable (String) -> Void)?
    private var activationObserver: NSObjectProtocol?
    private var keyObserver: NSObjectProtocol?

    private let backgroundInterval: TimeInterval = 0.2
    private let foregroundInterval: TimeInterval = 1.0
    private let leeway: DispatchTimeInterval = .milliseconds(50)

    func start(onChange: @escaping @Sendable (String) -> Void) {
        stop()
        self.onChange = onChange
        lastChangeCount = NSPasteboard.general.changeCount
        lastContent = ""

        let queue = DispatchQueue.main
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: backgroundInterval, leeway: leeway)
        timer.setEventHandler { [weak self] in
            self?.poll()
        }
        timer.resume()
        self.timer = timer

        activationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.poll()
            }
        }

        keyObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.poll()
            }
        }
    }

    func stop() {
        timer?.cancel()
        timer = nil
        if let observer = activationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = keyObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        activationObserver = nil
        keyObserver = nil
        onChange = nil
    }

    private func poll() {
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount

        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        let text: String?
        do {
            text = try readPasteboard(pasteboard)
        } catch {
            return
        }

        guard let text else { return }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard trimmed != lastContent else { return }

        lastContent = trimmed
        onChange?(trimmed)
    }

    private func readPasteboard(_ pasteboard: NSPasteboard) throws -> String? {
        guard let text = pasteboard.string(forType: .string) else {
            if pasteboard.changeCount != lastChangeCount {
                throw ClipboardError.readFailed
            }
            return nil
        }
        return text
    }
}
