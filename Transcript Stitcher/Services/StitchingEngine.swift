import Foundation

struct StitchResult: Sendable {
    let assembledText: String
}

struct StitchingEngine: Sendable {

    func stitch(newChunk: String, existingText: String) -> StitchResult {
        let normalizedNew = normalize(newChunk)
        let normalizedExisting = normalize(existingText)

        guard !normalizedNew.isEmpty else {
            return StitchResult(assembledText: existingText)
        }

        if normalizedExisting.isEmpty {
            return StitchResult(assembledText: normalizedNew)
        }

        let overlapLength = findOverlapLength(
            suffix: normalizedExisting,
            prefix: normalizedNew
        )

        if overlapLength > 0 {
            let newContent = String(normalizedNew.dropFirst(overlapLength))
            let merged = normalizedExisting + newContent
            return StitchResult(assembledText: merged)
        } else {
            let merged = normalizedExisting + "\n" + normalizedNew
            return StitchResult(assembledText: merged)
        }
    }

    private func normalize(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func findOverlapLength(suffix: String, prefix: String) -> Int {
        let maxOverlap = min(suffix.count, prefix.count)
        let minOverlap = 20

        guard maxOverlap >= minOverlap else { return 0 }

        for length in stride(from: maxOverlap, through: minOverlap, by: -1) {
            let suffixEnd = suffix.suffix(length)
            let prefixStart = prefix.prefix(length)

            if suffixEnd == prefixStart {
                return length
            }
        }

        return 0
    }
}
