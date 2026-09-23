## Features

- [ ] Add window state restoration with @SceneStorage to preserve transcript across app launches
- [ ] Implement document architecture for saving/loading transcripts

## Performance

- [ ] Replace timer-based clipboard polling with NSWorkspace notifications or DispatchSource for better responsiveness
- [ ] Optimize StitchingEngine overlap detection from O(n²) using suffix arrays or KMP algorithm
- [ ] Cache attributedText in AppState instead of recomputing on every render
- [ ] Implement incremental stitching instead of full replay on every fragment addition

## Code Quality

- [ ] Change ChunkRange.id from fragment index to UUID for safer fragment removal
- [ ] Extract repetitive undo registration into a helper method
- [ ] Replace magic numbers with named constants (poll interval, hue step)
- [ ] Refactor ClipboardMonitor to use AsyncStream instead of @Sendable callback
- [ ] Add error handling for clipboard access failures
- [ ] Enhance Fragment model with timestamp and source metadata
- [ ] Fix non-reactive undo/redo menu disabled state (UndoManager is not @Observable)
- [x] Remove duplicate Cmd+Shift+X keyboard shortcut (declared in both TranscriptStitcherApp and TranscriptView)

## Testing

- [ ] Add tests for AppState (undo/redo, fragment management)
- [ ] Add integration tests for clipboard → stitching → UI flow

## macOS Integration

- [x] Add .frame(idealWidth:idealHeight:) for better window sizing
