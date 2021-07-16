//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 06.07.2021.
//
import Foundation
import UIKit

public class PrivoAgeGate {
    private let dateFormatter = DateFormatter()
    private let ageGate = InternalAgeGate()

    public init() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    public func getAgeStatus(extUserId: String? = nil, countryCode: String? = nil, completionHandler: @escaping (AgeGateStatus?) -> Void) {
        if let agId = UserDefaults.standard.string(forKey: ageGate.AG_ID) {
            let record = AgStatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, agId: agId, extUserId: extUserId, countryCode: countryCode)
            PrivoInternal.rest.processAgStatus(data: record) { [weak self] r in
                let id = r?.ageGateIdentifier
                self?.ageGate.storeAgId(id)
                if (id != nil) {
                    completionHandler(r)
                } else {
                    self?.ageGate.getFpStatus(extUserId: extUserId,countryCode: countryCode,completionHandler: completionHandler)
                }
            }
        } else {
            ageGate.getFpStatus(extUserId: extUserId,countryCode: countryCode,completionHandler: completionHandler)
        }
    }
    
    public func getAgeStatusByBirthDate(birthDate: Date, extUserId: String? = nil, countryCode: String? = nil, completionHandler: @escaping (AgeGateStatus?) -> Void) {
        let textDate = dateFormatter.string(from: birthDate);
        ageGate.getFpId() { fpId in
            if let fpId = fpId {
                let record = FpStatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, fpId: fpId, birthDate: textDate, extUserId: extUserId, countryCode: countryCode)
                PrivoInternal.rest.processBirthDate(data: record) { [weak self] r in
                    if let id = r?.ageGateIdentifier {
                        self?.ageGate.storeAgId(id)
                    }
                    completionHandler(r)
                }
            } else {
                completionHandler(nil)
            }
        }

    }
}

fileprivate class InternalAgeGate {
    fileprivate let AG_ID = "privoAgId";
    fileprivate let FP_ID = "privoFpId";
    
    fileprivate func getFpId(completionHandler: @escaping (String?) -> Void) {
        if let fpId = UserDefaults.standard.string(forKey: FP_ID) {
            completionHandler(fpId)
        } else {
            if let fingerprint = try? DeviceFingerprint() {
                PrivoInternal.rest.generateFingerprint(fingerprint: fingerprint) { [weak self] r in
                    if let id = r?.id {
                        self?.storeFpId(id)
                    }
                    completionHandler(r?.id)
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    fileprivate func getFpStatus(extUserId: String? = nil, countryCode: String? = nil, completionHandler: @escaping (AgeGateStatus?) -> Void) {
        getFpId() { fpId in
            if let fpId = fpId {
                let record = FpStatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, fpId: fpId, birthDate: nil, extUserId: extUserId, countryCode: countryCode)
                PrivoInternal.rest.processFpStatus(data: record) { [weak self] r in
                    if let id = r?.ageGateIdentifier {
                        self?.storeAgId(id)
                    }
                    completionHandler(r)
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    fileprivate func storeAgId(_ id: String?) {
        if let id = id {
            UserDefaults.standard.set(id, forKey: self.AG_ID)
        } else {
            UserDefaults.standard.removeObject(forKey: self.AG_ID)
        }
    }
    fileprivate func storeFpId(_ id: String?) {
        if let id = id {
            UserDefaults.standard.set(id, forKey: self.FP_ID)
        } else {
            UserDefaults.standard.removeObject(forKey: self.FP_ID)
        }
    }
}

