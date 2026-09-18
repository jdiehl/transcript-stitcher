import Testing
@testable import Transcript_Stitcher

@Suite("StitchingService Tests")
@MainActor
struct StitchingServiceTests {

    private func chunks(_ service: StitchingService) async -> [ChunkRange] {
        await service.chunks
    }

    private func text(_ service: StitchingService) async -> String {
        await service.assembledText
    }

    @Test func addFragment_appendsChunk() async {
        let service = StitchingService()
        let result = await service.addFragment("first")
        #expect(result.chunks.count == 1)
        #expect(result.chunks[0].id == 0)
        #expect(result.chunks[0].start == 0)
        #expect(result.chunks[0].length == 5)
    }

    @Test func addFragment_multipleChunks() async {
        let service = StitchingService()
        _ = await service.addFragment("first")
        let result = await service.addFragment("second")
        #expect(result.chunks.count == 2)
        #expect(result.chunks[0].id == 0)
        #expect(result.chunks[1].id == 1)
    }

    @Test func addFragment_updatesAssembledText() async {
        let service = StitchingService()
        _ = await service.addFragment("Hello")
        let result = await service.addFragment("World")
        #expect(result.assembledText == "Hello\nWorld")
    }

    @Test func reset_clearsTextAndChunks() async {
        let service = StitchingService()
        _ = await service.addFragment("some text")
        _ = await service.addFragment("more text")
        await service.reset()
        let t = await text(service)
        let c = await chunks(service)
        #expect(t == "")
        #expect(c.isEmpty)
    }

    @Test func addFragment_afterReset_startsFresh() async {
        let service = StitchingService()
        _ = await service.addFragment("old content")
        await service.reset()
        let result = await service.addFragment("new content")
        #expect(result.assembledText == "new content")
        #expect(result.chunks.count == 1)
        #expect(result.chunks[0].id == 0)
    }

    @Test func addFragment_withOverlap_trimsLastChunk() async {
        let service = StitchingService()
        let a = "Hello World This is chunk A content here"
        let b = "This is chunk A content here and now B"
        _ = await service.addFragment(a)
        let result = await service.addFragment(b)
        #expect(result.assembledText == "Hello World This is chunk A content here and now B")
        #expect(result.chunks.count == 2)
        #expect(result.chunks[0].id == 0)
        #expect(result.chunks[0].length == 12)
        #expect(result.chunks[1].id == 1)
        #expect(result.chunks[1].start == 40)
        #expect(result.chunks[1].length == 10)
    }

    @Test func addFragment_cascadeRemoval_removesMultipleChunks() async {
        let service = StitchingService()
        let a = "Hello World This is chunk A content here"
        let b = "This is chunk A content here and now B"
        let abc = "Hello World This is chunk A content here and now B extra"
        _ = await service.addFragment(a)
        _ = await service.addFragment(b)
        let result = await service.addFragment(abc)
        #expect(result.assembledText == "Hello World This is chunk A content here and now B extra")
        #expect(result.chunks.count == 1)
        #expect(result.chunks[0].id == 2)
        #expect(result.chunks[0].start == 0)
        #expect(result.chunks[0].length == result.assembledText.count)
    }

    @Test func addFragment_subsetCreatesNoNewChunk() async {
        let service = StitchingService()
        let existing = "This is a long transcript with lots of content"
        let subset = "transcript with lots of content"
        _ = await service.addFragment(existing)
        let result = await service.addFragment(subset)
        #expect(result.assembledText == existing)
        #expect(result.chunks.count == 1)
        #expect(result.chunks[0].id == 0)
    }

    @Test func addFragment_identicalCreatesNoNewChunk() async {
        let service = StitchingService()
        let text = "This is some repeated text content"
        _ = await service.addFragment(text)
        let result = await service.addFragment(text)
        #expect(result.assembledText == text)
        #expect(result.chunks.count == 1)
        #expect(result.chunks[0].id == 0)
    }

    @Test func colorIndex_isStableAndNeverReused() async {
        let service = StitchingService()
        _ = await service.addFragment("first")
        _ = await service.addFragment("second")
        let result = await service.addFragment("third")
        let ids = result.chunks.map(\.id)
        #expect(ids == [0, 1, 2])
    }

    @Test func colorIndex_notReusedAfterRemoval() async {
        let service = StitchingService()
        let a = "Hello World This is chunk A content here"
        let b = "This is chunk A content here and now B"
        let abc = "Hello World This is chunk A content here and now B extra"
        _ = await service.addFragment(a)
        _ = await service.addFragment(b)
        _ = await service.addFragment(abc)
        let result = await service.addFragment("more stuff here to add")
        #expect(result.chunks.count == 2)
        #expect(result.chunks[0].id == 2)
        #expect(result.chunks[1].id == 3)
    }
}
