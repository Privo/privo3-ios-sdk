//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

protocol FpIdentifiable {
    var fpId: String { get async throws }
}

class FpIdService: FpIdentifiable {
    private let source: Restable
    private var storage: FpIdStorage
    
    init(source: Restable = Rest.shared,
         storage: FpIdStorage = AgeGateStorage()) {
        self.source = source
        self.storage = storage
    }
    
    var fpId: String {
        get async throws /*(PrivoError)*/ {
            return try await getFpId()
        }
    }
    
    private func getFpId() async throws /*(PrivoError)*/ -> String {
        if let fpId = storage.fpId {
            return fpId
        }
        
        let rawFpId = DeviceFingerprint()
        let fpIdResponse = try await source.generateFingerprint(fingerprint: rawFpId)
        let fpId = fpIdResponse.id
        storage.fpId = fpId

        return fpId
    }
}
