## Features

- [ ] Implement document architecture for saving/loading transcripts

## Code Quality

- [ ] Change ChunkRange.id from fragment index to UUID for safer fragment removal
- [ ] Extract repetitive undo registration into a helper method
- [ ] Replace magic numbers with named constants (poll interval, hue step)
- [ ] Refactor ClipboardMonitor to use AsyncStream instead of @Sendable callback
- [ ] Add error handling for clipboard access failures
- [ ] Enhance Fragment model with timestamp and source metadata
## Testing

- [x] Add tests for AppState (undo/redo, fragment management)
- [ ] Add integration tests for clipboard → stitching → UI flow

