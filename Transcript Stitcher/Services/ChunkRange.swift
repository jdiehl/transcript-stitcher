import Foundation

struct ChunkRange: Sendable, Identifiable {
    let id: Int
    var start: Int
    var length: Int
}
