# App Store Metadata

## App Name

Transcript Stitcher

## Subtitle

Reconstruct transcripts from clipboard copies

## Description

**The Problem**

Many transcripts—especially those in web-based meeting tools—don't let you copy the entire transcript in one operation. You can only select and copy a portion at a time, often with overlapping sections. Manually stitching these fragments together is tedious and error-prone.

**The Solution**

Transcript Stitcher watches your clipboard while you copy transcript fragments. It automatically detects overlapping text and merges the fragments into a single, coherent transcript. When you're done copying, you cut or copy the assembled transcript with one command and paste it wherever you need it.

**How It Works**

1. Encounter a transcript that can't be downloaded or copied in one go
2. Open Transcript Stitcher and start monitoring
3. Copy fragments from the transcript—scroll, select, copy, repeat
4. Watch the app window as fragments are automatically stitched together
5. When done, cut the transcript to copy it and stop monitoring
6. Paste the assembled transcript into your notes, document, or AI assistant

While monitoring is active, everything you copy is captured and placed into the app window. The app detects overlapping text and merges it automatically, so you don't need to worry about copying the same section twice.

**Privacy**

All processing happens locally on your device. No data is stored or sent over the network.

## Keywords

transcript, clipboard, meeting, notes, stitch, merge, copy, paste

## Category

Productivity

## Age Rating

4+

## Copyright

MIT, Author: Jonathan Diehl

## Support URL

https://github.com/jdiehl/transcript-stitcher/issues

## Privacy Policy URL

https://github.com/jdiehl/transcript-stitcher/blob/main/PRIVACY.md

## Pricing

Free

---

# App Review Notes

## What the App Does

Transcript Stitcher solves a common problem: many transcripts (especially from web-based meeting tools) cannot be downloaded or copied in one operation. Users can only select and copy portions at a time, often with overlapping sections.

The app watches the system clipboard while monitoring is active. When users copy transcript fragments, the app automatically detects overlapping text and merges the fragments into a single, coherent transcript. This eliminates the need for manual stitching of overlapping sections.

## How to Test

1. Launch the app
2. Start monitoring by pressing Command+R or clicking the Start button
3. Copy a block of text (e.g., a paragraph from a document or web page)
4. The text appears in the app window
5. Copy an overlapping block of text (the second block should share some text with the first)
6. The app merges the two blocks, removing the overlap
7. When finished, press Shift+Command+X to cut the assembled transcript (this copies it to clipboard and stops monitoring)
8. Paste the transcript into any text editor to verify it's complete and deduplicated

**Note:** While monitoring is active, everything copied to the clipboard is captured and placed into the app window. The app automatically detects and removes overlapping text.

## Monitoring Behavior

- The app monitors the system clipboard only while monitoring is active
- Monitoring starts when the user taps the Start button or presses Command+R
- Only text matching transcript-like patterns is processed
- Non-transcript clipboard content is ignored

## Privacy

- No data is stored persistently
- No data is sent over the network
- No data is shared with third parties
- Closing the app discards all captured content
- No login or account required
- No push notifications
- No analytics or telemetry

## Permissions

The app does not request any special system permissions.

## Known Limitations

- The stitching algorithm handles exact text overlaps only
- Very short overlaps (under 20 characters) are not detected
- The app does not handle out-of-order fragments
