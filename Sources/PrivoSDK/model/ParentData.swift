import Foundation

public struct ParentData {
    let roleIdentifier: String
    let email: String
    
    public init(roleIdentifier: String, email: String) {
        self.roleIdentifier = roleIdentifier
        self.email = email
    }
}
