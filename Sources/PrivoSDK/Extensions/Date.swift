import Foundation

extension Date {
    
    var toMilliseconds: Int64 { Int64(timeIntervalSince1970 * 1000) }

    init(milliseconds:Int) {
        self = Date().advanced(by: TimeInterval(integerLiteral: Int64(milliseconds / 1000)))
    }
    
}
