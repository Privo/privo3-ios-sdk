import Foundation

public enum BirthDatePrecision {
    case YYYYMMDD(String)
    case YYYYMM(String)
    case YYYY(String)
    case age(Int)
}

extension BirthDatePrecision {
    func toDate() -> Date? {
        let calendar = Calendar.current
        let currentDate = Date()
        var dateComponents = DateComponents()

        switch self {
        case .YYYYMMDD(let dateString):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
        case .YYYYMM(let dateString):
            let components = dateString.split(separator: "-")
            if components.count == 2,
               let year = Int(components[0]),
               let month = Int(components[1])
            {
                dateComponents.year = year
                dateComponents.month = month
                dateComponents.day = 1
                return calendar.date(from: dateComponents)
            }
        case .YYYY(let yearString):
            if let year = Int(yearString) {
                dateComponents.year = year
                dateComponents.month = 1
                dateComponents.day = 1
                return calendar.date(from: dateComponents)
            }
        case .age(let age):
            return calendar.date(byAdding: .year, value: -age, to: currentDate)
        }

        return nil
    }
}

