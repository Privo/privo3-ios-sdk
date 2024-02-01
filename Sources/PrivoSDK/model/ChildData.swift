import Foundation

public struct ChildData {
    public let birthdate: Date
    public let username: String
    public let displayname: String
    public let firstname: String
    public let lastname: String?
    
    public init(birthdate: Date,
                username: String,
                displayname: String? = nil,
                firstname: String,
                lastname: String? = nil
    ) {
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
