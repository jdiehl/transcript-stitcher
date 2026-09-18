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
        #expect(result.newChunkStart == 0)
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
        #expect(result.overlapLength == 28)
        #expect(result.newChunkStart == 57)
        #expect(result.newChunkLength == 20)
    }

    @Test func stitch_withOverlap_exactBoundary() {
        let overlap = "This is exactly twenty"
        let existing = "Start of text \(overlap)"
        let newFragment = "\(overlap) characters"
        let result = engine.stitch(newFragment: newFragment, existingText: existing)
        #expect(result.assembledText == "Start of text This is exactly twenty characters")
        #expect(result.newChunkStart == existing.count)
        #expect(result.newChunkLength == " characters".count)
    }

    @Test func stitch_noOverlap_concatenatesWithNewline() {
        let result = engine.stitch(newFragment: "completely different", existingText: "original text")
        #expect(result.assembledText == "original text\ncompletely different")
        #expect(result.overlapLength == 0)
        #expect(result.newChunkStart == 14)
        #expect(result.newChunkLength == 20)
    }

    @Test func stitch_overlapBelowMinimum_concatenates() {
        let existing = "text with short"
        let newFragment = "short overlap"
        let result = engine.stitch(newFragment: newFragment, existingText: existing)
        #expect(result.assembledText == "text with short\nshort overlap")
    }

    @Test func stitch_picksLongestOverlap() {
        let existing = "This is a test with some repeated content here"
        let newFragment = "some repeated content here and new stuff"
        let result = engine.stitch(newFragment: newFragment, existingText: existing)
        #expect(result.assembledText == "This is a test with some repeated content here and new stuff")
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
        #expect(result.newChunkLength == 0)
    }

    @Test func stitch_newFragmentIsSubset() {
        let existing = "This is a long transcript with lots of content"
        let newFragment = "transcript with lots of content"
        let result = engine.stitch(newFragment: newFragment, existingText: existing)
        #expect(result.assembledText == existing)
        #expect(result.newChunkLength == 0)
    }
}
