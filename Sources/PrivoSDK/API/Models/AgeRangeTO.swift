import Foundation

public struct AgeRangeTO: Codable, Hashable {
    public let start: Int
    public let end: Int
    public let jurisdiction: String?
}


extension AgeRangeTO {
    
    var convertTo: AgeRange {
        return .init(start: start, end: end, jurisdiction: jurisdiction)
    }
    
}
