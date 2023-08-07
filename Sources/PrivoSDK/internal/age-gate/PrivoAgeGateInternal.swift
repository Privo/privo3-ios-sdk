//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 31.03.2022.
//

import Foundation
import SwiftUI

internal class PrivoAgeGateInternal {
    
    let storage: AgeGateStorage
    let helpers: PrivoAgeHelpers
    private let permissionService: PrivoPermissionServiceType
    private let api: Rest
    
    init(permissionService: PrivoPermissionServiceType = PrivoPermissionService.shared,
         api: Rest = .shared) {
        self.api = api
        self.permissionService = permissionService
        self.storage = AgeGateStorage()
        self.helpers = PrivoAgeHelpers(self.storage.serviceSettings)
    }
    
    public func processStatus(
        userIdentifier: String?,
        nickname: String?,
        agId: String?,
        fpId: String,
        completionHandler: @escaping (AgeGateEvent) -> Void) {
        let record = StatusRecord(
            serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
            fpId: fpId,
            agId: agId,
            extUserId: userIdentifier
        )
        PrivoInternal.rest.processStatus(data: record) { response in
            if let response = response {
                let event = AgeGateEvent(
                    status: response.status.toStatus(),
                    userIdentifier: response.extUserId,
                    nickname: nickname,
                    agId: response.agId ?? agId,
                    ageRange: response.ageRange,
                    countryCode: response.countryCode
                )
                completionHandler(event)
            } else {
                completionHandler(AgeGateEvent(
                    status: AgeGateStatus.Undefined,
                    userIdentifier: userIdentifier,
                    nickname: nickname,
                    agId: agId,
                    ageRange: nil,
                    countryCode: nil
                ))
            }
        }
    }
    
    internal func getStatusEvent(_ userIdentifier: String?, nickname: String?, completionHandler: @escaping (AgeGateEvent) -> Void) {
        storage.getStoredAgeGateId(userIdentifier: userIdentifier, nickname: nickname) { [weak self] agId in
            self?.storage.getFpId { fpId in
                if (agId == nil && nickname != nil) {
                    // for case of a new nickname
                    self?.processStatus(
                        userIdentifier: nil,
                        nickname: nickname,
                        agId: nil,
                        fpId: fpId,
                        completionHandler: completionHandler
                    )
                } else {
                    self?.processStatus(
                        userIdentifier: userIdentifier,
                        nickname: nickname,
                        agId: agId,
                        fpId: fpId,
                        completionHandler: completionHandler
                    )
                }
            }
        }
    }
    
    public func linkUser(
        userIdentifier: String,
        agId: String,
        nickname: String?,
        completionHandler: @escaping (AgeGateEvent) -> Void) {
            
            storage.getAgeGateStoredEntities() { entities in
                let isKnownAgId = entities.contains { $0.agId == agId}
                if (isKnownAgId == false) {
                    // send flag to metrics and continue (not stop)
                    let warning = AgeGateLinkWarning(description: "Age Gate Id wasn't found in the store during Age Gate 'link user' call", agIdEntities: entities)
                    if let data = try? JSONEncoder().encode(warning) {
                        let stringData = String(decoding: data, as: UTF8.self)
                        let event = AnalyticEvent(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, data: stringData)
                        PrivoInternal.rest.sendAnalyticEvent(event)
                    }
                }
                
                let record = LinkUserStatusRecord(
                    serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                    agId: agId,
                    extUserId: userIdentifier
                )
                PrivoInternal.rest.processLinkUser(data: record) { response in
                    if let response = response {
                        let event = AgeGateEvent(
                            status: response.status.toStatus(),
                            userIdentifier: response.extUserId,
                            nickname: nickname,
                            agId: response.agId ?? agId,
                            ageRange: response.ageRange,
                            countryCode: response.countryCode
                        )
                        completionHandler(event)
                    } else {
                        completionHandler(AgeGateEvent(
                            status: AgeGateStatus.Undefined,
                            userIdentifier: userIdentifier,
                            nickname: nickname,
                            agId: agId,
                            ageRange: nil,
                            countryCode: nil
                        ))
                    }
                }
            }
    }
    
    internal func getAgeGateState(userIdentifier: String?,
                                  niсkname: String?,
                                  completionHandler: @escaping (AgeState?) -> Void
    ) {
        storage.getStoredAgeGateId(userIdentifier: userIdentifier, nickname: niсkname) { [weak self] agId in
            self?.storage.getFpId() { fpId in
                self?.storage.serviceSettings.getSettings { settings in
                    completionHandler(AgeState(
                        fpId: fpId,
                        agId: agId,
                        settings: settings
                    ))
                }
            }
        }
    }
    
    
    internal func runAgeGateByBirthDay(_ data: CheckAgeData, completionHandler: @escaping (AgeGateEvent?) -> Void) {
        storage.getFpId { fpId in
            let record = FpStatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                                        fpId: fpId,
                                        birthDate: data.birthDateYYYYMMDD,
                                        birthDateYYYYMM: data.birthDateYYYYMM,
                                        birthDateYYYY: data.birthDateYYYY,
                                        age: data.age,
                                        extUserId: data.userIdentifier,
                                        countryCode: data.countryCode)
            PrivoInternal.rest.processBirthDate(data: record, completionHandler: { [weak self] r in
                guard let self = self else { return }
                guard let response = r, let status = self.helpers.toStatus(response.action) else {
                    completionHandler(nil); return
                }
                let event = AgeGateEvent(status: status,
                                         userIdentifier: response.extUserId,
                                         nickname: data.nickname,
                                         agId: response.agId,
                                         ageRange: response.ageRange,
                                         countryCode: response.countryCode)
                let runAgeGateActions: [AgeGateAction] = [.Consent, .IdentityVerify, .AgeVerify]
                guard (runAgeGateActions.contains(response.action)) else { completionHandler(event); return  }
                self.runAgeGate(data, prevEvent: event, recheckRequired: nil, completionHandler: completionHandler)
            }, ageEstimationHandler: { [weak self] error in
                guard let self = self else { return }
                permissionService.checkCameraPermission { [weak self] granted in
                    guard let self = self else { return }
                    self.runAgeGate(data, prevEvent: nil, recheckRequired: .AgeEstimationRequired, completionHandler: completionHandler)
                }
            })
        }
    }
    internal func recheckAgeGateByBirthDay(_ data: CheckAgeData, completionHandler: @escaping (AgeGateEvent?) -> Void) {
        storage.getStoredAgeGateId(userIdentifier: data.userIdentifier, nickname: data.nickname) { [weak self] agId in
            guard let agId = agId else { return }
            // make a rest call
            let record = RecheckStatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                                             agId: agId,
                                             birthDate: data.birthDateYYYYMMDD,
                                             birthDateYYYYMM: data.birthDateYYYYMM,
                                             birthDateYYYY: data.birthDateYYYY,
                                             age: data.age,
                                             countryCode: data.countryCode)
            PrivoInternal.rest.processRecheck(data: record, completionHandler: { [weak self] r in
                guard let self = self else { return }
                guard let response = r, let status = self.helpers.toStatus(response.action) else {
                    completionHandler(nil)
                    return
                }
                let event = AgeGateEvent(status: status,
                                         userIdentifier: response.extUserId,
                                         nickname: data.nickname,
                                         agId: response.agId,
                                         ageRange: response.ageRange,
                                         countryCode: response.countryCode)
                guard (response.action == AgeGateAction.Consent ||
                       response.action == AgeGateAction.IdentityVerify ||
                       response.action == AgeGateAction.AgeVerify) else { completionHandler(event); return }
                self.runAgeGate(data, prevEvent: event, recheckRequired: nil, completionHandler: completionHandler)
            }, ageEstimationHandler: { [weak self] error in
                guard let self = self else { return }
                permissionService.checkCameraPermission { [weak self] granted in
                    guard let self = self else { return }
                    self.runAgeGate(data, prevEvent: nil, recheckRequired: .AgeEstimationRecheckRequired, completionHandler: completionHandler)
                }
            })
        }
    }
    
    internal func runAgeGate(
        _ data: CheckAgeData,
        prevEvent: AgeGateEvent?,
        recheckRequired: AgeGateInternalAction?,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) {
        
        getAgeGateState(userIdentifier: data.userIdentifier, niсkname: data.nickname) { state  in
            guard let state = state else { completionHandler(nil); return }
            let ageGateData = CheckAgeStoreData(
                serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                settings: state.settings,
                userIdentifier: data.userIdentifier,
                nickname: data.nickname,
                countryCode: data.countryCode,
                birthDateYYYYMMDD: data.birthDateYYYYMMDD,
                birthDateYYYYMM: data.birthDateYYYYMM,
                birthDateYYYY: data.birthDateYYYY,
                redirectUrl: PrivoInternal.configuration.ageGatePublicUrl.withPath("/index.html#/age-gate-loading")!.absoluteString,
                agId: state.agId,
                fpId: state.fpId
            )
            UIApplication.shared.showView(false) {
                AgeGateView(
                    ageGateData : ageGateData,
                    targetPage: self.helpers.getStatusTargetPage(prevEvent?.status, recheckRequired: recheckRequired),
                    onFinish: { events in
                        events.forEach { event in
                            if (event.status == AgeGateStatus.IdentityVerified || event.status == AgeGateStatus.AgeVerified) {
                                // sunc status to get Correct Age Range
                                self.processStatus(
                                    userIdentifier: event.userIdentifier,
                                    nickname: data.nickname,
                                    agId: event.agId,
                                    fpId: state.fpId,
                                    completionHandler: completionHandler
                                )
                            } else {
                                completionHandler(event)
                            }
                        }
                        if (events.isEmpty) {
                            completionHandler(nil)
                        }
                        await UIApplication.shared.dismissTopView()
                    })
            }
        }
    }
    
    internal func showAgeGateIdentifier(userIdentifier: String?, nickname: String?) {
        storage.getStoredAgeGateId(userIdentifier: userIdentifier, nickname: nickname) { [weak self] agId in
            self?.storage.getFpId() { fpId in
                self?.storage.serviceSettings.getSettings { settings in
                    let ageGateData = CheckAgeStoreData(
                        serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                        settings: settings,
                        userIdentifier: userIdentifier,
                        nickname: nickname,
                        countryCode: nil,
                        birthDateYYYYMMDD: nil,
                        birthDateYYYYMM: nil,
                        birthDateYYYY: nil,
                        redirectUrl: nil,
                        agId: agId,
                        fpId: fpId
                    )
                    UIApplication.shared.showView(false) {
                        AgeGateView(
                            ageGateData : ageGateData,
                            targetPage: "age-gate-identifier",
                            finishCriteria: "identifier-closed",
                            onFinish:  { _ in
                                await UIApplication.shared.dismissTopView()
                            }
                        )
                    }
                }
            }
        }
    }
    
    internal func hide() {
        UIApplication.shared.dismissTopView()
    }
}


//MARK: - PrivoAgeGateInternal async function's wrappers

extension PrivoAgeGateInternal {
    
    public func processStatus(userIdentifier: String?, nickname: String?, agId: String?, fpId: String) async -> AgeGateEvent {
        let record = StatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                                  fpId: fpId,
                                  agId: agId,
                                  extUserId: userIdentifier)
        let response = await api.processStatus(data: record)
        guard let response = response else {
            let event = AgeGateEvent(status: AgeGateStatus.Undefined,
                                     userIdentifier: userIdentifier,
                                     nickname: nickname,
                                     agId: agId,
                                     ageRange: nil,
                                     countryCode: nil)
            return event
        }
        let event = AgeGateEvent(status: response.status.toStatus(),
                                 userIdentifier: response.extUserId,
                                 nickname: nickname,
                                 agId: response.agId ?? agId,
                                 ageRange: response.ageRange,
                                 countryCode: response.countryCode)
        return event
    }
    
    public func linkUser(userIdentifier: String, agId: String, nickname: String?) async -> AgeGateEvent {
        let entities = storage.getAgeGateStoredEntities()
        let isKnownAgId = entities.contains { $0.agId == agId }
        if (!isKnownAgId) {
            // send flag to metrics and continue (not stop)
            let warning = AgeGateLinkWarning(description: "Age Gate Id wasn't found in the store during Age Gate 'link user' call",
                                             agIdEntities: entities)
            if let stringData = warning.convertToString() {
                let event = AnalyticEvent(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, data: stringData)
                api.sendAnalyticEvent(event)
            }
        }
        let record = LinkUserStatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                                          agId: agId,
                                          extUserId: userIdentifier)
        let response = await api.processLinkUser(data: record)
        guard let response = response else {
            let event = AgeGateEvent(status: AgeGateStatus.Undefined,
                                     userIdentifier: userIdentifier,
                                     nickname: nickname,
                                     agId: agId,
                                     ageRange: nil,
                                     countryCode: nil)
            return event
        }
        let event = AgeGateEvent(status: response.status.toStatus(),
                                 userIdentifier: response.extUserId,
                                 nickname: nickname,
                                 agId: response.agId ?? agId,
                                 ageRange: response.ageRange,
                                 countryCode: response.countryCode)
        return event
    }
    
    func getStatusEvent(_ userIdentifier: String?, nickname: String?) async -> AgeGateEvent {
        let agId = storage.getStoredAgeGateId(userIdentifier: userIdentifier, nickname: nickname)
        let fpId = await storage.getFpId()
        guard let agId = agId else {
            let event = await processStatus(userIdentifier: nil, nickname: nickname, agId: nil, fpId: fpId)
            return event
        }
        let event = await processStatus(userIdentifier: userIdentifier, nickname: nickname, agId: agId, fpId: fpId)
        return event
    }
    
    func getAgeGateState(userIdentifier: String?, niсkname: String?) async -> AgeState? {
        let agId = storage.getStoredAgeGateId(userIdentifier: userIdentifier, nickname: niсkname)
        let fpId = await storage.getFpId()
        do {
            let settings = try await storage.serviceSettings.getSettings()
            guard let settings = settings else { return nil }
            let state = AgeState(fpId: fpId, agId: agId, settings: settings)
            return state
        } catch _ {
            return nil
        }
    }
    
    func runAgeGateByBirthDay(_ data: CheckAgeData) async -> AgeGateEvent? {
        let fpId = await storage.getFpId()
        let record = FpStatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                                    fpId: fpId,
                                    birthDate: data.birthDateYYYYMMDD,
                                    birthDateYYYYMM: data.birthDateYYYYMM,
                                    birthDateYYYY: data.birthDateYYYY,
                                    age: data.age,
                                    extUserId: data.userIdentifier,
                                    countryCode: data.countryCode)
        do {
            let response = try await api.processBirthDate(data: record)
            guard let response = response, let status = helpers.toStatus(response.action) else {
                return nil
            }
            let event = AgeGateEvent(status: status,
                                     userIdentifier: response.extUserId,
                                     nickname: data.nickname,
                                     agId: response.agId,
                                     ageRange: response.ageRange,
                                     countryCode: response.countryCode)
            let runAgeGateActions: [AgeGateAction] = [.Consent, .IdentityVerify, .AgeVerify]
            guard runAgeGateActions.contains(response.action) else { return event }
            let newEvent = await runAgeGate(data, prevEvent: event, recheckRequired: nil)
            return newEvent
        } catch is CustomServerErrorResponse {
            _ = await permissionService.checkCameraPermission()
            let newEvent = await runAgeGate(data, prevEvent: nil, recheckRequired: .AgeEstimationRequired)
            return newEvent
        } catch let error {
            fatalError("UNEXPECTED ERROR: \(error)")
        }
    }
    
    func recheckAgeGateByBirthDay(_ data: CheckAgeData) async -> AgeGateEvent? {
        guard let agId = storage.getStoredAgeGateId(userIdentifier: data.userIdentifier, nickname: data.nickname) else { return nil }
        let record = RecheckStatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                                         agId: agId,
                                         birthDate: data.birthDateYYYYMMDD,
                                         birthDateYYYYMM: data.birthDateYYYYMM,
                                         birthDateYYYY: data.birthDateYYYY,
                                         age: data.age,
                                         countryCode: data.countryCode)
        do {
            let response = try await api.processRecheck(data: record)
            guard let response = response, let status = helpers.toStatus(response.action) else {
                return nil
            }
            let event = AgeGateEvent(status: status,
                                     userIdentifier: response.extUserId,
                                     nickname: data.nickname,
                                     agId: response.agId,
                                     ageRange: response.ageRange,
                                     countryCode: response.countryCode)
            let actions: [AgeGateAction] = [.Consent, .IdentityVerify, .AgeVerify]
            guard actions.contains(response.action) else { return event }
            let newEvent = await runAgeGate(data, prevEvent: event, recheckRequired: nil)
            return newEvent
        } catch is CustomServerErrorResponse {
            _ = await permissionService.checkCameraPermission()
            let event = await runAgeGate(data, prevEvent: nil, recheckRequired: .AgeEstimationRecheckRequired)
            return event
        } catch let error {
            fatalError("UNEXPECTED ERROR: \(error)")
        }
    }
    
    func runAgeGate(_ data: CheckAgeData,
                   prevEvent: AgeGateEvent?,
                   recheckRequired: AgeGateInternalAction?) async -> AgeGateEvent? {
        guard let state = await getAgeGateState(userIdentifier: data.userIdentifier, niсkname: data.nickname) else { return nil }
        let ageGateData = CheckAgeStoreData(serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                                           settings: state.settings,
                                           userIdentifier: data.userIdentifier,
                                           nickname: data.nickname,
                                           countryCode: data.countryCode,
                                           birthDateYYYYMMDD: data.birthDateYYYYMMDD,
                                           birthDateYYYYMM: data.birthDateYYYYMM,
                                           birthDateYYYY: data.birthDateYYYY,
                                           redirectUrl: PrivoInternal.configuration.ageGatePublicUrl.withPath("/index.html#/age-gate-loading")!.absoluteString,
                                           agId: state.agId,
                                           fpId: state.fpId)
        let targetPage = helpers.getStatusTargetPage(prevEvent?.status, recheckRequired: recheckRequired)
        let result: AgeGateEvent? = await withCheckedContinuation { @MainActor promise in
           UIApplication.shared.showView(false, content: {
               AgeGateView(ageGateData: ageGateData,
                           targetPage: targetPage,
                           onFinish: { [weak self] events in
                   guard let self = self, !events.isEmpty else { promise.resume(returning: nil); return }
                   for e in events {
                       if (e.status == AgeGateStatus.IdentityVerified || e.status == AgeGateStatus.AgeVerified) {
                               let result = await self.processStatus(userIdentifier: e.userIdentifier,
                                                                     nickname: data.nickname,
                                                                     agId: e.agId,
                                                                     fpId: state.fpId)
                               promise.resume(returning: result)
                       } else {
                           promise.resume(returning: e)
                       }
                   }
                   await self.hide()
                })
           })
        }
        return result
    }
    
    func showAgeGateIdentifier(userIdentifier: String?, nickname: String?) async {
        do {
            let agId = storage.getStoredAgeGateId(userIdentifier: userIdentifier, nickname: nickname)
            let fpId = await storage.getFpId()
            guard let settings = try await storage.serviceSettings.getSettings() else { return }
            let ageGateData = CheckAgeStoreData(serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                                                settings: settings,
                                                userIdentifier: userIdentifier,
                                                nickname: nickname,
                                                countryCode: nil,
                                                birthDateYYYYMMDD: nil,
                                                birthDateYYYYMM: nil,
                                                birthDateYYYY: nil,
                                                redirectUrl: nil,
                                                agId: agId,
                                                fpId: fpId)
            await UIApplication.shared.showView(false) {
                AgeGateView(ageGateData : ageGateData,
                            targetPage: "age-gate-identifier",
                            finishCriteria: "identifier-closed",
                            onFinish: { [weak self]  _ in
                    await self?.hide()
                })
            }
        } catch _ {
            
        }
    }
    
    @MainActor
    func hide() async {
        UIApplication.shared.dismissTopView()
    }
    
}
