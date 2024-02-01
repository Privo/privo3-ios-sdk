import Foundation

enum RoleIdentifier: String {
    case parentStandard = "STANDARD_PARENT_1"
    case childDefault = "DEFAULT_CHILD"
}

struct ParentChildPair: Encodable {
    let roleIdentifier: String
    let email: String
    let minorRegistrations: [MinorRegistration]
    
    struct MinorRegistration: Encodable {
        let userName: String
        let firstName: String
        let lastName: String?
        let birthDateYYYYMMDD: String
        let sendParentEmail: Bool
        let roleIdentifier: String
        let sendCongratulationsEmail: Bool
        let attributes: [Attribute]
        
        init(child: ChildData) {
            self.firstName = child.firstname
            self.lastName = child.lastname
            self.userName = child.username
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            self.birthDateYYYYMMDD = dateFormatter.string(from: child.birthdate)
            self.sendParentEmail = true
            self.roleIdentifier = RoleIdentifier.childDefault.rawValue
            self.sendCongratulationsEmail = true
            self.attributes = [
                .displayName(child.displayname)
            ]
        }
    }
    
    struct Attribute: Encodable {
        let name: String
        let value: String
        
        static func displayName(_ value: String) -> Self {
            return Self(name: "DisplayName", value: value)
        }
    }
}

