import Foundation

public struct ChildData {
    let roleIdentifier: String
    let birthdate: BirthDatePrecision
    let username: String
    let displayname: String
    let firstname: String
    let lastname: String?
    
    public init(roleIdentifier: String,
                birthdate: BirthDatePrecision,
                username: String,
                displayname: String? = nil,
                firstname: String,
                lastname: String? = nil
    ) {
        self.roleIdentifier = roleIdentifier
        self.username = username
        if let displayname = displayname {
            self.displayname = displayname
        } else {
            self.displayname = username
        }
        self.firstname = firstname
        self.lastname = lastname
        self.birthdate = birthdate
    }
}
