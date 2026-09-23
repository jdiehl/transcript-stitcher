import Foundation

struct ChunkRange: Sendable, Identifiable, Equatable {
    let id: Int
    var start: Int
    var length: Int
}
