//
//  File.swift
//  
//
//  Created by Andrey Yo on 24.11.2023.
//


import Foundation

protocol FpIdentifiable {
    var fpId: String? { get async }
}

class FpIdService: FpIdentifiable {
    private let source: Restable
    private var storage: FpIdStorage
    
    init(source: Restable = Rest.shared,
         storage: FpIdStorage = AgeGateStorage()) {
        self.source = source
        self.storage = storage
    }
    
    var fpId: String? {
        get async {
            return await getFpId()
        }
    }
    
    private func getFpId() async -> String? {
        if let fpId = storage.fpId {
            return fpId
        }
        
        let rawFpId = DeviceFingerprint()
        let fpIdResponse = await source.generateFingerprint(fingerprint: rawFpId)
        
        guard let fpId = fpIdResponse?.id else {
            return nil
        }
        storage.fpId = fpId

        return fpId
    }
}
