import Foundation

extension Date {
    
    func toMilliseconds() -> Int64 {
        Int64(self.timeIntervalSince1970 * 1000)
    }

    init(milliseconds:Int) {
        self = Date().advanced(by: TimeInterval(integerLiteral: Int64(milliseconds / 1000)))
    }
}
