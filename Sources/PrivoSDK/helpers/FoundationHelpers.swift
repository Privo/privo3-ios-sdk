import Foundation

extension DateFormatter {
    convenience init(format: String) {
        self.init()
        dateFormat = format
        timeZone = TimeZone(secondsFromGMT: 0)
    }
}
