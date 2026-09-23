import Foundation
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

    @Test func updateChunks_multipleChunks_removesLast_keepsOthers() {
        let existing = [
            ChunkRange(id: 0, start: 0, length: 12),
            ChunkRange(id: 1, start: 12, length: 28)
        ]
        let result = engine.updateChunks(existing: existing, chunkLength: 28, textLength: 40)
        #expect(result.count == 1)
        #expect(result[0].length == 12)
    }

    // MARK: - Replay Tests

    @Test func replay_emptyFragments_returnsEmpty() {
        let result = engine.replay(fragments: [])
        #expect(result.assembledText == "")
        #expect(result.chunks.isEmpty)
    }

    @Test func replay_singleFragment_returnsCorrectState() {
        let fragments = [Fragment(text: "Hello world")]
        let result = engine.replay(fragments: fragments)
        #expect(result.assembledText == "Hello world")
        #expect(result.chunks.count == 1)
        #expect(result.chunks[0].id == 0)
        #expect(result.chunks[0].start == 0)
        #expect(result.chunks[0].length == 11)
    }

    @Test func replay_multipleNonOverlappingFragments() {
        let fragments = [
            Fragment(text: "First"),
            Fragment(text: "Second"),
            Fragment(text: "Third")
        ]
        let result = engine.replay(fragments: fragments)
        #expect(result.assembledText == "First\nSecond\nThird")
        #expect(result.chunks.count == 3)
        #expect(result.chunks[0].id == 0)
        #expect(result.chunks[1].id == 1)
        #expect(result.chunks[2].id == 2)
    }

    @Test func replay_overlappingFragments_trimsChunks() {
        let fragments = [
            Fragment(text: "Hello world and more text"),
            Fragment(text: "world and more text plus extra")
        ]
        let result = engine.replay(fragments: fragments)
        #expect(result.assembledText == "Hello world and more text plus extra")
        #expect(result.chunks.count == 2)
        #expect(result.chunks[0].id == 0)
        #expect(result.chunks[1].id == 1)
    }

    // MARK: - AppendFragment Tests

    @Test func appendFragment_emptyFragment_returnsExisting() {
        let result = engine.appendFragment(
            newFragment: "",
            fragmentIndex: 1,
            existingText: "existing text",
            existingChunks: [ChunkRange(id: 0, start: 0, length: 13)]
        )
        #expect(result.assembledText == "existing text")
        #expect(result.chunks.count == 1)
        #expect(result.chunks[0].id == 0)
    }

    @Test func appendFragment_toEmptyText_createsChunk() {
        let result = engine.appendFragment(
            newFragment: "Hello world",
            fragmentIndex: 0,
            existingText: "",
            existingChunks: []
        )
        #expect(result.assembledText == "Hello world")
        #expect(result.chunks.count == 1)
        #expect(result.chunks[0].id == 0)
        #expect(result.chunks[0].start == 0)
        #expect(result.chunks[0].length == 11)
    }

    @Test func appendFragment_withOverlap_trimsExistingChunks() {
        let existing = [ChunkRange(id: 0, start: 0, length: 23)]
        let result = engine.appendFragment(
            newFragment: "world and more text plus extra",
            fragmentIndex: 1,
            existingText: "Hello world and more text",
            existingChunks: existing
        )
        #expect(result.assembledText == "Hello world and more text plus extra")
        #expect(result.chunks.count == 2)
        #expect(result.chunks[0].id == 0)
        #expect(result.chunks[1].id == 1)
    }

    @Test func appendFragment_noOverlap_concatenatesWithNewline() {
        let result = engine.appendFragment(
            newFragment: "Second",
            fragmentIndex: 1,
            existingText: "First",
            existingChunks: [ChunkRange(id: 0, start: 0, length: 5)]
        )
        #expect(result.assembledText == "First\nSecond")
        #expect(result.chunks.count == 2)
        #expect(result.chunks[0].id == 0)
        #expect(result.chunks[1].id == 1)
    }

    @Test func appendFragment_assignsCorrectChunkId() {
        let result = engine.appendFragment(
            newFragment: "New text",
            fragmentIndex: 42,
            existingText: "Existing",
            existingChunks: []
        )
        #expect(result.chunks.count == 1)
        #expect(result.chunks[0].id == 42)
    }

}
