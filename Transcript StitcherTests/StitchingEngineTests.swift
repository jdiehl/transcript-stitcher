import Testing
@testable import Transcript_Stitcher

@Suite("StitchingEngine Tests")
@MainActor
struct StitchingEngineTests {
    let engine = StitchingEngine()

    @Test func stitch_emptyNewFragment_returnsExisting() {
        let result = engine.stitch(newFragment: "", existingText: "existing")
        #expect(result.assembledText == "existing")
        #expect(result.newChunkLength == 0)
    }

    @Test func stitch_whitespaceOnlyNewFragment_returnsExisting() {
        let result = engine.stitch(newFragment: "   \n\t  ", existingText: "existing")
        #expect(result.assembledText == "existing")
        #expect(result.newChunkLength == 0)
    }

    @Test func stitch_emptyExisting_returnsNew() {
        let result = engine.stitch(newFragment: "new text", existingText: "")
        #expect(result.assembledText == "new text")
        #expect(result.newChunkLength == 8)
    }

    @Test func stitch_bothEmpty_returnsEmpty() {
        let result = engine.stitch(newFragment: "", existingText: "")
        #expect(result.assembledText == "")
        #expect(result.newChunkLength == 0)
    }

    @Test func stitch_withOverlap_mergesCorrectly() {
        let existing = "This is the beginning of the transcript with some content"
        let newFragment = "transcript with some content and more text added"
        let result = engine.stitch(newFragment: newFragment, existingText: existing)
        #expect(result.assembledText == "This is the beginning of the transcript with some content and more text added")
      #expect(result.newChunkLength == newFragment.count)
    }

    @Test func stitch_noOverlap_concatenatesWithNewline() {
        let existing = "original text"
        let newFragment = "completely different"
        let result = engine.stitch(newFragment: newFragment, existingText: existing)
        #expect(result.assembledText == "original text\ncompletely different")
        #expect(result.newChunkLength == newFragment.count)
    }

    @Test func stitch_shortOverlap_mergesCorrectly() {
        let existing = "text with a"
        let newFragment = "a overlap"
        let result = engine.stitch(newFragment: newFragment, existingText: existing)
        #expect(result.assembledText == "text with a overlap")
        #expect(result.newChunkLength == newFragment.count)
    }

    @Test func stitch_picksLongestOverlap() {
        let existing = "This is a test with some repeated content here"
        let newFragment = "some repeated content here and new stuff"
        let result = engine.stitch(newFragment: newFragment, existingText: existing)
        #expect(result.assembledText == "This is a test with some repeated content here and new stuff")
      #expect(result.newChunkLength == newFragment.count)
    }

    @Test func stitch_normalizesCRLF() {
        let result = engine.stitch(newFragment: "line1\r\nline2", existingText: "")
        #expect(result.assembledText == "line1\nline2")
    }

    @Test func stitch_normalizesCR() {
        let result = engine.stitch(newFragment: "line1\rline2", existingText: "")
        #expect(result.assembledText == "line1\nline2")
    }

    @Test func stitch_trimsWhitespace() {
        let result = engine.stitch(newFragment: "  \n  text  \n  ", existingText: "  \n  existing  \n  ")
        #expect(result.assembledText == "existing\ntext")
    }

    @Test func stitch_multipleFragmentsSequential() {
        var result = engine.stitch(newFragment: "First chunk", existingText: "")
        result = engine.stitch(newFragment: "Second chunk", existingText: result.assembledText)
        result = engine.stitch(newFragment: "Third chunk", existingText: result.assembledText)
        #expect(result.assembledText == "First chunk\nSecond chunk\nThird chunk")
    }

    @Test func stitch_identicalFragments_returnsSameText() {
        let text = "This is some repeated text content"
        let result = engine.stitch(newFragment: text, existingText: text)
        #expect(result.assembledText == text)
      #expect(result.newChunkLength == text.count)
    }

    @Test func stitch_newFragmentIsSubset() {
        let existing = "This is a long transcript with lots of content"
        let newFragment = "transcript with lots of content"
        let result = engine.stitch(newFragment: newFragment, existingText: existing)
        #expect(result.assembledText == existing)
        #expect(result.newChunkLength == newFragment.count)
    }

    @Test func updateChunks_noExistingChunks_returnsEmpty() {
        let result = engine.updateChunks(existing: [], chunkLength: 5, textLength: 5)
        #expect(result.isEmpty)
    }

    @Test func updateChunks_singleChunk_noOverlap() {
        let existing = [ChunkRange(id: 0, start: 0, length: 5)]
        let result = engine.updateChunks(existing: existing, chunkLength: 6, textLength: 12)
        #expect(result.count == 1)
        #expect(result[0].length == 5)
    }

    @Test func updateChunks_singleChunk_partialTrim() {
        let existing = [ChunkRange(id: 0, start: 0, length: 40)]
        let result = engine.updateChunks(existing: existing, chunkLength: 10, textLength: 50)
        #expect(result.count == 1)
        #expect(result[0].length == 40)
    }

    @Test func updateChunks_singleChunk_fullyOverwritten() {
        let existing = [ChunkRange(id: 0, start: 0, length: 40)]
        let result = engine.updateChunks(existing: existing, chunkLength: 50, textLength: 50)
        #expect(result.isEmpty)
    }

    @Test func updateChunks_multipleChunks_cascadeRemoval() {
        let existing = [
            ChunkRange(id: 0, start: 0, length: 40),
            ChunkRange(id: 1, start: 40, length: 10)
        ]
        let result = engine.updateChunks(existing: existing, chunkLength: 50, textLength: 50)
        #expect(result.isEmpty)
    }

    @Test func updateChunks_multipleChunks_partialTrimOfLast() {
        let existing = [
            ChunkRange(id: 0, start: 0, length: 12),
            ChunkRange(id: 1, start: 12, length: 28)
        ]
        let result = engine.updateChunks(existing: existing, chunkLength: 10, textLength: 50)
        #expect(result.count == 2)
        #expect(result[0].length == 12)
        #expect(result[1].length == 28)
    }

    @Test func updateChunks_multipleChunks_removesLast_keepsOthers() {
        let existing = [
            ChunkRange(id: 0, start: 0, length: 12),
            ChunkRange(id: 1, start: 12, length: 28)
        ]
        let result = engine.updateChunks(existing: existing, chunkLength: 28, textLength: 40)
        #expect(result.count == 1)
        #expect(result[0].length == 12)
    }
}
