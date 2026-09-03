# TODO

## UI

- [ ] Make monitoring state visually obvious (e.g. color/icon change, status text, animated indicator)
- [ ] Show captured fragment count and character count in the main view
- [ ] Add a clear visual distinction between monitoring and idle states

## Performance

- [ ] Move stitching off the main actor to avoid UI stalls on large transcripts

## Testing

- [ ] Add unit tests for StitchingEngine (exact overlap, duplicates, empty input, large inputs)
- [ ] Add unit tests for TranscriptDetector (true positives, false positives)
- [ ] Add unit tests for ClipboardMonitor state transitions
