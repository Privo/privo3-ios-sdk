import Foundation

struct RecheckStatusRecord: Codable, Hashable {
    let serviceIdentifier: String
    let agId: String
    let birthDate: String? // YYY-MM-DD "2021-03-04"
    let birthDateYYYYMM: String? // "2021-03"
    let birthDateYYYY: String? // "2021"
    let age: Int? // 31
    let countryCode: String?
}

extension RecheckStatusRecord {
    init(_ serviceIdentifier: String, _ agId: String, _ data: CheckAgeData) {
        self.init(serviceIdentifier: PrivoService.settings.serviceIdentifier,
                  agId: agId,
                  birthDate: data.birthDateYYYYMMDD,
                  birthDateYYYYMM: data.birthDateYYYYMM,
                  birthDateYYYY: data.birthDateYYYY,
                  age: data.age,
                  countryCode: data.countryCode)
    }
}
