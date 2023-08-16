import Foundation

public struct AgeRange: Codable, Hashable {
    public let start: Int
    public let end: Int
    public let jurisdiction: String?
}
