import Foundation

actor StitchingService {
    private let engine = StitchingEngine()
    private(set) var assembledText: String = ""
    private(set) var chunkCount: Int = 0

    func addChunk(_ text: String) -> StitchResult {
        let result = engine.stitch(newChunk: text, existingText: assembledText)
        assembledText = result.assembledText
        chunkCount += 1
        return result
    }

    func getText() -> String {
        assembledText
    }

    func getChunkCount() -> Int {
        chunkCount
    }

    func reset() {
        assembledText = ""
        chunkCount = 0
    }
}
