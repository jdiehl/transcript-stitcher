import Foundation

struct StitchResult: Sendable {
    let assembledText: String
    let newChunkLength: Int
}

struct ReplayResult: Sendable {
    let assembledText: String
    let chunks: [ChunkRange]
}

struct AppendResult: Sendable {
    let assembledText: String
    let chunks: [ChunkRange]
}

struct StitchingEngine: Sendable {

    nonisolated func stitch(newFragment: String, existingText: String) -> StitchResult {
        let normalizedNew = normalize(newFragment)
        let normalizedExisting = normalize(existingText)

        guard !normalizedNew.isEmpty else {
            return StitchResult(
                assembledText: existingText,
                newChunkLength: 0
            )
        }

        if normalizedExisting.isEmpty {
            return StitchResult(
                assembledText: normalizedNew,
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
                newChunkLength: normalizedNew.count
            )
        } else {
            let merged = normalizedExisting + "\n" + normalizedNew
            return StitchResult(
                assembledText: merged,
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

    // O(n²) brute-force approach. Simpler than KMP/Z-algorithm and sufficient for typical
    // transcript fragments (100-1000 chars). Revisit only if profiling shows this as a bottleneck.
    private nonisolated func findOverlapLength(suffix: String, prefix: String) -> Int {
        let maxOverlap = min(suffix.count, prefix.count)
        let minOverlap = 1

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

    nonisolated func updateChunks(
        existing: [ChunkRange],
        chunkLength: Int,
        textLength: Int
    ) -> [ChunkRange] {
        let chunkStart = textLength - chunkLength
        var chunks = existing

        while let last = chunks.last {
            let chunkEnd = last.start + last.length
            if chunkEnd <= chunkStart {
                break
            }

            let surviving = chunkStart - last.start
            if surviving <= 0 {
                chunks.removeLast()
            } else {
                chunks[chunks.count - 1].length = surviving
                break
            }
        }

        return chunks
    }

    nonisolated func replay(fragments: [Fragment]) -> ReplayResult {
        var assembledText = ""
        var chunks: [ChunkRange] = []

        for (index, fragment) in fragments.enumerated() {
            let result = appendFragment(
                newFragment: fragment.text,
                fragmentIndex: index,
                existingText: assembledText,
                existingChunks: chunks
            )
            assembledText = result.assembledText
            chunks = result.chunks
        }

        return ReplayResult(assembledText: assembledText, chunks: chunks)
    }

    nonisolated func appendFragment(
        newFragment: String,
        fragmentIndex: Int,
        existingText: String,
        existingChunks: [ChunkRange]
    ) -> AppendResult {
        let stitch = stitch(newFragment: newFragment, existingText: existingText)
        guard stitch.newChunkLength > 0 else {
            return AppendResult(assembledText: existingText, chunks: existingChunks)
        }

        let assembledText = stitch.assembledText
        var chunks = updateChunks(
            existing: existingChunks,
            chunkLength: stitch.newChunkLength,
            textLength: assembledText.count
        )
        let chunkStart = assembledText.count - stitch.newChunkLength
        chunks.append(ChunkRange(id: fragmentIndex, start: chunkStart, length: stitch.newChunkLength))

        return AppendResult(assembledText: assembledText, chunks: chunks)
    }
}
