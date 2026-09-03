# Patchwork

**A macOS menu bar application that reconstructs Microsoft Teams meeting transcripts from multiple copied transcript fragments.**

---

# Product Overview

## Vision

When transcript download is disabled in Microsoft Teams, users often resort to copying transcript content manually. Unfortunately, Teams frequently copies only a subset of the transcript, resulting in missing sections, duplicate content, and a frustrating manual reconstruction process.

Patchwork solves this by continuously monitoring the macOS clipboard, capturing transcript fragments as they are copied, intelligently identifying overlaps, and assembling a single coherent transcript that can be exported or pasted into AI assistants, documentation tools, or notes.

---

# Problem Statement

### Current Workflow

1. User opens a Teams transcript.
2. Transcript download is unavailable.
3. User selects transcript content and copies it.
4. Only part of the transcript is copied.
5. User scrolls and repeats the process.
6. The resulting transcript contains:
   - Missing sections
   - Duplicated sections
   - Unclear ordering
   - Significant manual cleanup effort

### Desired Workflow

1. Launch Patchwork.
2. Open a Teams meeting transcript.
3. Copy transcript sections repeatedly.
4. Patchwork automatically:
   - Captures copied fragments
   - Detects overlaps
   - Deduplicates content
   - Merges fragments into a unified transcript
5. User exports or copies the reconstructed transcript.

---

# Goals

## Primary Goals

- Capture transcript fragments from the clipboard automatically.
- Reconstruct a complete transcript with minimal user intervention.
- Remove duplicated content.
- Surface likely missing sections.
- Allow easy export to AI tools and documentation systems.

## Non-Goals

- Direct integration with Teams.
- Transcript scraping.
- Browser automation.
- Microsoft Graph integration.
- Network-based transcript retrieval.

Patchwork only works with content explicitly copied by the user.

---

# Target Users

### Primary

- Engineers
- Consultants
- Researchers
- Product managers
- Architects
- Project leads

### Common Scenario

Users who need access to meeting transcripts but cannot download them due to organizational policy restrictions.

---

# User Stories

### Capture Transcript Fragments

**As a user**

I want Patchwork to automatically detect transcript content copied to my clipboard

**So that**

I do not need to manually import transcript fragments.

---

### Merge Content Automatically

**As a user**

I want transcript fragments merged automatically

**So that**

I do not need to manually compare overlapping sections.

---

### Detect Missing Areas

**As a user**

I want the application to identify likely gaps

**So that**

I know where additional copying may be required.

---

### Export Final Transcript

**As a user**

I want a clean transcript export

**So that**

I can use it in AI agents, notes, documentation, or knowledge systems.

---

# Technical Stack

## Platform

- macOS 15+
- Apple Silicon

## Language

- Swift 6

## UI Framework

- SwiftUI

## Menu Bar Support

- MenuBarExtra

## Clipboard Access

- NSPasteboard

## Storage

- SQLite

Recommended library:

- GRDB

## Reactive Layer

- Observation
- Combine (where needed)

---

# High-Level Architecture

```text
┌─────────────────────┐
│ Clipboard Monitor   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Transcript Detector │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Stitching Engine    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Session Storage     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ SwiftUI Interface   │
└─────────────────────┘
```

---

# Core Components

## 1. Clipboard Monitor

### Responsibilities

- Monitor clipboard changes.
- Detect newly copied content.
- Ignore duplicate clipboard entries.
- Ignore short or irrelevant clipboard content.
- Forward candidate transcript text to processing.

### Acceptance Criteria

- Detect clipboard updates within one second.
- Minimal CPU impact while idle.
- No duplicate ingestion.

---

## 2. Transcript Detector

### Responsibilities

Determine whether clipboard content resembles transcript data.

### Signals

- Repeating conversational structure
- Speaker names
- Timestamps
- Many short lines
- Consistent formatting patterns

### Example

```text
John Smith 10:31 AM
Let's begin.

Jane Doe 10:32 AM
Sounds good.
```

### Acceptance Criteria

- Low false-positive rate.
- Non-transcript clipboard content ignored.

---

## 3. Stitching Engine

### Responsibilities

Merge transcript fragments into a unified transcript.

### Strategy 1: Exact Overlap Detection

Input:

```text
Agenda item one
Budget discussion
Hiring update
```

```text
Hiring update
Roadmap review
Next sprint
```

Output:

```text
Agenda item one
Budget discussion
Hiring update
Roadmap review
Next sprint
```

---

### Strategy 2: Fuzzy Overlap Detection

Handle minor formatting differences:

```text
Agenda Item 1
```

and

```text
Agenda item one
```

Potential implementation:

- Longest common subsequence
- Similarity scoring
- RapidFuzz-like matching algorithms reimplemented in Swift

---

### Strategy 3: Transcript-Aware Merging

Parse transcript entries into structured records.

```swift
TranscriptEntry
```

```text
speaker
timestamp
message
```

Merge based on structured information rather than text alone.

### Acceptance Criteria

- Remove duplicates.
- Preserve ordering.
- Produce readable output.

---

## 4. Session Manager

### Responsibilities

Manage multiple transcript reconstruction sessions.

### Features

- New session
- Rename session
- Archive session
- Delete session
- Resume previous session

### Example

```text
Architecture Review
Sprint Planning
Customer Workshop
Team Sync
```

---

## 5. Gap Detection

### Responsibilities

Detect likely missing transcript regions.

### Example

```text
10:01
10:02
10:03
10:08
```

Possible gap:

```text
10:04 - 10:07
```

### UI Behaviour

Display:

```text
Possible missing transcript section detected.
```

### Goal

Guide users toward missing content before export.

---

## 6. Export Engine

### Export Formats

#### Plain Text

```text
John:
Hello

Jane:
Hi
```

#### Markdown

```markdown
# Meeting Transcript

## John

Hello

## Jane

Hi
```

#### JSON

```json
{
  "speaker": "John",
  "timestamp": "10:31",
  "message": "Hello"
}
```

### Primary User Action

```text
Copy Complete Transcript
```

---

# User Interface

## Menu Bar View

```text
Patchwork

Current Session
Architecture Review

Entries: 568
Chunks: 21
Gaps: 1

Open Session
Copy Transcript
Export
```

---

## Main Window

### Sidebar

```text
Architecture Review
Sprint Planning
Customer Call
Retrospective
```

### Transcript View

```text
10:01 John
Good morning everyone.

10:02 Sarah
Let's get started.
```

### Actions

```text
Copy Transcript
Export
Rename Session
Clear Session
Delete Session
```

---

# Data Model

## TranscriptSession

```swift
struct TranscriptSession {
    let id: UUID
    var name: String
    let createdAt: Date
    var updatedAt: Date
}
```

## TranscriptChunk

```swift
struct TranscriptChunk {
    let id: UUID
    let rawText: String
    let capturedAt: Date
}
```

## TranscriptEntry

```swift
struct TranscriptEntry {
    let id: UUID
    let speaker: String?
    let timestamp: Date?
    let message: String
}
```

---

# Performance Requirements

## Throughput

- Handle transcripts with 50,000+ lines.
- Process large clipboard payloads without UI lag.

## Responsiveness

- Clipboard detection under one second.
- Near-instant transcript rendering.

## Resource Usage

- Low idle CPU consumption.
- Low memory footprint.

---

# Privacy & Security

## Privacy Principles

- Local-first architecture.
- No cloud services.
- No telemetry.
- No analytics.
- No outbound network traffic required.

## Data Ownership

- All transcript data remains on the user's device.
- Users can delete all stored transcript history at any time.

---

# Future Enhancements

## v2

- OCR from screenshots
- Drag-and-drop transcript import
- Speaker statistics
- Search across sessions
- AI-generated summaries

## v3

- Local LLM integration
- Action item extraction
- Decision detection
- Semantic cleanup of transcripts
- Knowledge-base export

---

# Success Metrics

The product is successful when users can:

1. Copy transcript fragments from Teams without manual organization.
2. Automatically accumulate transcript content in Patchwork.
3. Obtain a single reconstructed transcript with minimal duplication.
4. Identify likely missing sections.
5. Export the resulting transcript into AI agents, documentation systems, or note-taking tools.

---

# Guiding Principle

> Recovering a usable transcript with minimal effort is more important than perfect reconstruction.

A transcript that is automatically reconstructed to 95% completeness provides significantly more value than a perfectly accurate solution that requires extensive manual intervention.