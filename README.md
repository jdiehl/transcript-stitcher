# Transcript Stitcher

macOS menu bar app that reconstructs transcripts from multiple clipboard copies.

## Usage

1. Launch the app
2. Copy transcript fragments from Teams or other sources
3. The app automatically detects overlaps and stitches them together
4. Press **⌘C** to copy the assembled transcript

## Keyboard Shortcuts

- **⌘C** - Copy transcript to clipboard
- **⌘R** - Start/Stop clipboard monitoring
- **⌘X** - Clear transcript

## Build

Requires Xcode 16+ and macOS 15+.

```bash
xcodebuild -project "Transcript Stitcher.xcodeproj" -scheme "Transcript Stitcher"
```

## Release

Push a version tag to trigger automated build and release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## License

MIT
