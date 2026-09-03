import Testing
@testable import Transcript_Stitcher

@Suite("StitchingEngine Tests")
@MainActor
struct StitchingEngineTests {
    let engine = StitchingEngine()

    @Test func stitch_emptyNewChunk_returnsExisting() {
        let result = engine.stitch(newChunk: "", existingText: "existing")
        #expect(result.assembledText == "existing")
    }

    @Test func stitch_whitespaceOnlyNewChunk_returnsExisting() {
        let result = engine.stitch(newChunk: "   \n\t  ", existingText: "existing")
        #expect(result.assembledText == "existing")
    }

    @Test func stitch_emptyExisting_returnsNew() {
        let result = engine.stitch(newChunk: "new text", existingText: "")
        #expect(result.assembledText == "new text")
    }

    @Test func stitch_bothEmpty_returnsEmpty() {
        let result = engine.stitch(newChunk: "", existingText: "")
        #expect(result.assembledText == "")
    }

    @Test func stitch_withOverlap_mergesCorrectly() {
        let existing = "This is the beginning of the transcript with some content"
        let newChunk = "transcript with some content and more text added"
        let result = engine.stitch(newChunk: newChunk, existingText: existing)
        #expect(result.assembledText == "This is the beginning of the transcript with some content and more text added")
    }

    @Test func stitch_withOverlap_exactBoundary() {
        let overlap = "This is exactly twenty"
        let existing = "Start of text \(overlap)"
        let newChunk = "\(overlap) characters"
        let result = engine.stitch(newChunk: newChunk, existingText: existing)
        #expect(result.assembledText == "Start of text This is exactly twenty characters")
    }

    @Test func stitch_noOverlap_concatenatesWithNewline() {
        let result = engine.stitch(newChunk: "completely different", existingText: "original text")
        #expect(result.assembledText == "original text\ncompletely different")
    }

    @Test func stitch_overlapBelowMinimum_concatenates() {
        let existing = "text with short"
        let newChunk = "short overlap"
        let result = engine.stitch(newChunk: newChunk, existingText: existing)
        #expect(result.assembledText == "text with short\nshort overlap")
    }

    @Test func stitch_picksLongestOverlap() {
        let existing = "This is a test with some repeated content here"
        let newChunk = "some repeated content here and new stuff"
        let result = engine.stitch(newChunk: newChunk, existingText: existing)
        #expect(result.assembledText == "This is a test with some repeated content here and new stuff")
    }

    @Test func stitch_normalizesCRLF() {
        let result = engine.stitch(newChunk: "line1\r\nline2", existingText: "")
        #expect(result.assembledText == "line1\nline2")
    }

    @Test func stitch_normalizesCR() {
        let result = engine.stitch(newChunk: "line1\rline2", existingText: "")
        #expect(result.assembledText == "line1\nline2")
    }

    @Test func stitch_trimsWhitespace() {
        let result = engine.stitch(newChunk: "  \n  text  \n  ", existingText: "  \n  existing  \n  ")
        #expect(result.assembledText == "existing\ntext")
    }

    @Test func stitch_multipleChunksSequential() {
        var result = engine.stitch(newChunk: "First chunk", existingText: "")
        result = engine.stitch(newChunk: "Second chunk", existingText: result.assembledText)
        result = engine.stitch(newChunk: "Third chunk", existingText: result.assembledText)
        #expect(result.assembledText == "First chunk\nSecond chunk\nThird chunk")
    }

    @Test func stitch_identicalChunks_returnsSameText() {
        let text = "This is some repeated text content"
        let result = engine.stitch(newChunk: text, existingText: text)
        #expect(result.assembledText == text)
    }

    @Test func stitch_newChunkIsSubset() {
        let existing = "This is a long transcript with lots of content"
        let newChunk = "transcript with lots of content"
        let result = engine.stitch(newChunk: newChunk, existingText: existing)
        #expect(result.assembledText == existing)
    }
}
