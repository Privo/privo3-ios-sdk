//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

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
