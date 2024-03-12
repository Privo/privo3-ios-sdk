import Foundation

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
        
        init(child: ChildData) throws /* (PrivoError) */ {
            self.roleIdentifier = child.roleIdentifier
            self.firstName = child.firstname
            self.lastName = child.lastname
            self.userName = child.username
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            guard let childBirthdate = child.birthdate.toDate()
            else {
                throw PrivoError.incorrectInputData(AgeGateError.incorrectDateOfBirht)
            }
            self.birthDateYYYYMMDD = dateFormatter.string(from: childBirthdate)
            self.sendParentEmail = true
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

