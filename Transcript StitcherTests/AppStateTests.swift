import Foundation
import Testing
@testable import Transcript_Stitcher

@Suite("AppState Tests")
@MainActor
struct AppStateTests {

    @Test func addFragment_single_updatesState() {
        let state = AppState()
        state.addFragment("Hello world")
        #expect(state.fragments.count == 1)
        #expect(state.assembledText == "Hello world")
        #expect(state.chunks.count == 1)
    }

    @Test func addFragment_multiple_accumulates() {
        let state = AppState()
        state.addFragment("First")
        state.addFragment("Second")
        #expect(state.fragments.count == 2)
        #expect(state.assembledText == "First\nSecond")
    }

    @Test func redo_afterUndo_restoresState() {
        let state = AppState()
        state.addFragment("Hello")
        state.addFragment("World")
        state.undoManager.undo()
        state.undoManager.redo()
        #expect(state.fragments.count == 2)
        #expect(state.assembledText == "Hello\nWorld")
    }

    @Test func clear_resetsState() {
        let state = AppState()
        state.addFragment("Hello")
        state.clear()
        #expect(state.fragments.isEmpty)
        #expect(state.assembledText.isEmpty)
        #expect(!state.isMonitoring)
    }

    @Test func hasContent_reflectsText() {
        let state = AppState()
        #expect(!state.hasContent)
        state.addFragment("Hello")
        #expect(state.hasContent)
    }
}
