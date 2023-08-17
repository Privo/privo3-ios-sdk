import Foundation

struct FpStatusRecord: Codable, Hashable {
    let serviceIdentifier: String
    let fpId: String
    let birthDate: String? // YYY-MM-DD "2021-03-04"
    let birthDateYYYYMM: String? // "2021-03"
    let birthDateYYYY: String? // "2021"
    let age: Int? // 31
    let extUserId: String?
    let countryCode: String?
}

extension FpStatusRecord {
    
    init(_ serviceIdentifier: String, _ fpId: String, _ data: CheckAgeData) {
        self.init(serviceIdentifier: serviceIdentifier,
                  fpId: fpId,
                  birthDate: data.birthDateYYYYMMDD,
                  birthDateYYYYMM: data.birthDateYYYYMM,
                  birthDateYYYY: data.birthDateYYYY,
                  age: data.age,
                  extUserId: data.userIdentifier,
                  countryCode: data.countryCode)
    }
    
}
