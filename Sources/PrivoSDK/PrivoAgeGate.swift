//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 06.07.2021.
//
import Foundation
import UIKit

public class PrivoAgeGate {
    private let AG_ID = "privoAgId";
    private let FP_ID = "privoFpId";
    private let dateFormatter = DateFormatter()

    public init() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    private func getFpId(completionHandler: @escaping (String?) -> Void) {
        if let fpId = UserDefaults.standard.string(forKey: FP_ID) {
            completionHandler(fpId)
        } else {
            if let fingerprint = try? DeviceFingerprint() {
                PrivoInternal.rest.generateFingerprint(fingerprint: fingerprint) { r in
                    if let id = r?.id {
                        UserDefaults.standard.set(id, forKey: self.FP_ID)
                    }
                    completionHandler(r?.id)
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    private func getFpStatus(extUserId: String? = nil, countryCode: String? = nil, completionHandler: @escaping (AgeGateStatus?) -> Void) {
        getFpId() { fpId in
            if let fpId = fpId {
                let record = FpStatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, fpId: fpId, birthDate: nil, extUserId: extUserId, countryCode: countryCode)
                PrivoInternal.rest.processFpStatus(data: record, completionHandler: completionHandler)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    public func getAgeStatus(extUserId: String? = nil, countryCode: String? = nil, completionHandler: @escaping (AgeGateStatus?) -> Void) {
        if let agId = UserDefaults.standard.string(forKey: AG_ID) {
            let record = AgStatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, agId: agId, extUserId: extUserId, countryCode: countryCode)
            PrivoInternal.rest.processAgStatus(data: record) { r in
                if let id = r?.ageGateIdentifier {
                    UserDefaults.standard.set(id, forKey: self.AG_ID)
                    completionHandler(r)
                } else {
                    UserDefaults.standard.removeObject(forKey: self.AG_ID)
                    completionHandler(nil)
                }
            }
        } else {
            getFpStatus(extUserId: extUserId,countryCode: countryCode,completionHandler: completionHandler)
        }
    }
    
    public func getAgeStatusByBirthDate(birthDate: Date, extUserId: String? = nil, countryCode: String? = nil, completionHandler: @escaping (AgeGateStatus?) -> Void) {
        let textDate = dateFormatter.string(from: birthDate);
        getFpId() { fpId in
            if let fpId = fpId {
                let record = FpStatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, fpId: fpId, birthDate: textDate, extUserId: extUserId, countryCode: countryCode)
                PrivoInternal.rest.processBirthDate(data: record) { r in
                    if let id = r?.ageGateIdentifier {
                        UserDefaults.standard.set(id, forKey: self.AG_ID)
                    }
                    completionHandler(r)
                }
            } else {
                completionHandler(nil)
            }
        }

    }
}
