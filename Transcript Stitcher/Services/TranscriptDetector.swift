import Foundation

enum TranscriptDetector {
    static func isLikelyTranscript(_ text: String) -> Bool {
        score(text) >= 3
    }

    private static func score(_ text: String) -> Int {
        let lines = text.split(whereSeparator: \.isNewline).map(String.init)
        guard lines.count >= 2 else { return 0 }

        var points = 0

        let speakerPattern = try? Regex(#"^[A-Z][A-Za-zÀ-ÿ\s.'\-]{0,40}:\s"#)
        let speakerWithTimestamp = try? Regex(#"^[A-Z][A-Za-zÀ-ÿ\s.'\-]{0,40}\s*[\(\[]?\d{1,2}:\d{2}(?::\d{2})?\s*(?:AM|PM|am|pm)?[\)\]]?\s*:"#)
        let timestampPattern = try? Regex(#"\d{1,2}:\d{2}(?::\d{2})?\s*(?:AM|PM|am|pm)?"#)

        var speakerMatches = 0
        var timestampMatches = 0

        for line in lines {
            if (try? speakerWithTimestamp?.firstMatch(in: line)) != nil {
                speakerMatches += 1
            } else if (try? speakerPattern?.firstMatch(in: line)) != nil {
                speakerMatches += 1
            }
            if (try? timestampPattern?.firstMatch(in: line)) != nil {
                timestampMatches += 1
            }
        }

        if speakerMatches >= 3 {
            points += 3
        } else if speakerMatches >= 1 {
            points += 1
        }

        if timestampMatches >= 2 {
            points += 2
        } else if timestampMatches >= 1 {
            points += 1
        }

        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let avgLength = nonEmptyLines.isEmpty ? 0 : nonEmptyLines.reduce(0) { $0 + $1.count } / nonEmptyLines.count

        if nonEmptyLines.count >= 5 && avgLength < 120 {
            points += 2
        } else if nonEmptyLines.count >= 3 && avgLength < 200 {
            points += 1
        }

        let uniqueStarts = Set(nonEmptyLines.prefix(20).map { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return String(trimmed.prefix(30))
        })
        if uniqueStarts.count >= nonEmptyLines.prefix(20).count / 2 {
            points += 1
        }

        return points
    }
}
