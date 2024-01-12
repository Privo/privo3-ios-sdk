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
