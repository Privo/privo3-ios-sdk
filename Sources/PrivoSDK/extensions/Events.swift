//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

extension AgeGateEventInternal {
    
    func toEvent(nickname: String?) -> AgeGateEvent? {
        guard let status = toStatus else  { return nil }
        return .init(status: status,
                     userIdentifier: userIdentifier,
                     nickname: nickname,
                     agId: agId,
                     ageRange: ageRange,
                     countryCode: countryCode)
    }
    
    private var toStatus: AgeGateStatus? {
        if status == .Closed {
            return nil
        } else {
            return .init(rawValue: status.rawValue)
        }
    }
    
}


extension AgeVerificationEventInternal {
    
    var toEvent: AgeVerificationEvent? {
        guard let status = toStatus else { return nil }
        return .init(status: status, profile: profile)
    }
    
    private var toStatus: AgeVerificationStatus? {
        guard status != .Closed else { return nil }
        return .init(rawValue: status.rawValue)
    }
    
}
