import Foundation

struct StitchResult: Sendable {
    let assembledText: String
    let overlapLength: Int
    let newChunkStart: Int
    let newChunkLength: Int
}

struct StitchingEngine: Sendable {

    nonisolated func stitch(newFragment: String, existingText: String) -> StitchResult {
        let normalizedNew = normalize(newFragment)
        let normalizedExisting = normalize(existingText)

        guard !normalizedNew.isEmpty else {
            return StitchResult(
                assembledText: existingText,
                overlapLength: 0,
                newChunkStart: existingText.count,
                newChunkLength: 0
            )
        }

        if normalizedExisting.isEmpty {
            return StitchResult(
                assembledText: normalizedNew,
                overlapLength: 0,
                newChunkStart: 0,
                newChunkLength: normalizedNew.count
            )
        }

        let overlapLength = findOverlapLength(
            suffix: normalizedExisting,
            prefix: normalizedNew
        )

        if overlapLength > 0 {
            let newContent = String(normalizedNew.dropFirst(overlapLength))
            let merged = normalizedExisting + newContent
            return StitchResult(
                assembledText: merged,
                overlapLength: overlapLength,
                newChunkStart: normalizedExisting.count,
                newChunkLength: newContent.count
            )
        } else {
            let merged = normalizedExisting + "\n" + normalizedNew
            return StitchResult(
                assembledText: merged,
                overlapLength: 0,
                newChunkStart: normalizedExisting.count + 1,
                newChunkLength: normalizedNew.count
            )
        }
    }

    private nonisolated func normalize(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private nonisolated func findOverlapLength(suffix: String, prefix: String) -> Int {
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
