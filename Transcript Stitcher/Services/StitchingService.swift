import Foundation

struct StitchServiceResult: Sendable {
    let assembledText: String
    let chunks: [ChunkRange]
}

actor StitchingService {
    private let engine = StitchingEngine()
    private(set) var assembledText: String = ""
    private(set) var chunks: [ChunkRange] = []
    private var nextColorIndex: Int = 0

    func addFragment(_ text: String) -> StitchServiceResult {
        let result = engine.stitch(newFragment: text, existingText: assembledText)
        assembledText = result.assembledText

        if result.newChunkLength > 0 {
            if result.overlapLength > 0 {
                var remaining = result.overlapLength
                while remaining > 0, let last = chunks.last {
                    if last.length <= remaining {
                        chunks.removeLast()
                        remaining -= last.length
                    } else {
                        chunks[chunks.count - 1].length -= remaining
                        remaining = 0
                    }
                }
            }

            let chunk: ChunkRange
            if chunks.isEmpty {
                chunk = ChunkRange(
                    id: nextColorIndex,
                    start: 0,
                    length: assembledText.count
                )
            } else {
                chunk = ChunkRange(
                    id: nextColorIndex,
                    start: result.newChunkStart,
                    length: result.newChunkLength
                )
            }
            nextColorIndex += 1
            chunks.append(chunk)
        }

        return StitchServiceResult(assembledText: assembledText, chunks: chunks)
    }

    func reset() {
        assembledText = ""
        chunks = []
        nextColorIndex = 0
    }
}
