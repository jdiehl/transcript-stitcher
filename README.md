# Transcript Stitcher

macOS app that reconstructs transcripts from multiple clipboard copies.

## The Problem

Many transcripts—especially those in web-based meeting tools—don't let you copy the entire transcript in one operation. You can only select and copy a portion at a time, often with overlapping sections. Manually stitching these fragments together is tedious and error-prone.

## The Solution

Transcript Stitcher watches your clipboard while you copy transcript fragments. It automatically detects overlapping text and merges the fragments into a single, coherent transcript. When you're done copying, you cut or copy the assembled transcript with one command and paste it wherever you need it.

## Workflow

1. **Encounter a transcript** that can't be downloaded or copied in one go
2. **Open Transcript Stitcher** and monitoring starts automatically
3. **Copy fragments** from the transcript—scroll, select, copy, repeat
4. **Watch the app window** as fragments are automatically stitched together
5. **When done, copy or cut the transcript** (Shift+Command+C or X) to copy it and stop monitoring
6. **Paste** the assembled transcript into your notes, document, or AI assistant

While monitoring is active, everything you copy is captured and placed into the app window. The app detects overlapping text and merges it automatically, so you don't need to worry about copying the same section twice.

## Keyboard Shortcuts

- **Command+R** - Start/Stop clipboard monitoring
- **Shift+Command+C** - Copy transcript to clipboard (stops monitoring)
- **Shift+Command+X** - Cut transcript (copy and clear, stops monitoring)

## Build

Requires Xcode 16+ and macOS 15+.

```bash
xcodebuild -project "Transcript Stitcher.xcodeproj" -scheme "Transcript Stitcher"
```

## Release

Push a version tag to trigger automated build and release:

```bash
git tag 1.0
git push origin 1.0
```

## Support

Report issues at [github.com/jdiehl/transcript-stitcher/issues](https://github.com/jdiehl/transcript-stitcher/issues)

## License

MIT
