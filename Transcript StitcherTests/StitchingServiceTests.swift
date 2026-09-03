import Testing
@testable import Transcript_Stitcher

@Suite("StitchingService Tests")
@MainActor
struct StitchingServiceTests {
    @Test func addChunk_incrementsChunkCount() async {
        let service = StitchingService()
        _ = await service.addChunk("first")
        _ = await service.addChunk("second")
        _ = await service.addChunk("third")
        let count = await service.getChunkCount()
        #expect(count == 3)
    }

    @Test func addChunk_updatesAssembledText() async {
        let service = StitchingService()
        _ = await service.addChunk("Hello")
        _ = await service.addChunk("World")
        let text = await service.getText()
        #expect(text == "Hello\nWorld")
    }

    @Test func reset_clearsTextAndCount() async {
        let service = StitchingService()
        _ = await service.addChunk("some text")
        _ = await service.addChunk("more text")
        await service.reset()
        let text = await service.getText()
        let count = await service.getChunkCount()
        #expect(text == "")
        #expect(count == 0)
    }

    @Test func getText_returnsCurrentState() async {
        let service = StitchingService()
        _ = await service.addChunk("test content")
        let text = await service.getText()
        let assembled = await service.assembledText
        #expect(text == assembled)
    }

    @Test func addChunk_afterReset_startsFresh() async {
        let service = StitchingService()
        _ = await service.addChunk("old content")
        await service.reset()
        _ = await service.addChunk("new content")
        let text = await service.getText()
        let count = await service.getChunkCount()
        #expect(text == "new content")
        #expect(count == 1)
    }
}
