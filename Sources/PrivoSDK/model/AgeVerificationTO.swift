import Foundation

struct AgeVerificationTO : Encodable, Decodable {
    let verificationIdentifier: String;
    let status: AgeVerificationStatusInternal;
    
    let firstName: String;
    let birthDate: String; // "2022-05-24";
    let parentFirstName: String;
    let parentLastName: String;
    let parentEmail: String?;
    let mobilePhone: String?;
    let email: String?;
}
