import Foundation
import SwiftUI

class PrivoAgeGateService {
    
    //MARK: - Internal properties
    
    let storage: PrivoAgeGateStorage
    let helpers: PrivoAgeHelpers
    
    //MARK: - Private properties
    
    private let permissionService: PrivoPermissionServiceType
    private let api: Rest
    
    //MARK: - Internal initialisers
    
    init(permissionService: PrivoPermissionServiceType = PrivoPermissionService.shared,
         api: Rest = .shared,
         storage: PrivoAgeGateStorage = .init()) {
        self.api = api
        self.permissionService = permissionService
        self.storage = storage
        self.helpers = PrivoAgeHelpers(storage.serviceSettings)
    }
    
    //MARK: - Public functions
    
    public func processStatus(userIdentifier: String?,
                              nickname: String?,
                              agId: String?,
                              fpId: String) async -> AgeGateEvent {
        let record = StatusRecord(serviceIdentifier: PrivoService.settings.serviceIdentifier,
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
        let event = AgeGateEvent(status: response.status.toStatus,
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
            api.sendAnalyticEvent(.init(serviceIdentifier: PrivoService.settings.serviceIdentifier, data: warning))
        }
        let record = LinkUserStatusRecord(serviceIdentifier: PrivoService.settings.serviceIdentifier,
                                          agId: agId,
                                          extUserId: userIdentifier)
        let response = await api.processLinkUser(data: record)
        guard let response = response else {
            return .init(status: .Undefined,
                         userIdentifier: userIdentifier,
                         nickname: nickname,
                         agId: agId,
                         ageRange: nil,
                         countryCode: nil)
        }
        let event = AgeGateEvent(nickName: nickname, data: response)
        return event
    }
    
    //MARK: - Internal functions
    
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
        let record = FpStatusRecord.init(PrivoService.settings.serviceIdentifier, fpId, data)
        do {
            let response = try await api.processBirthDate(data: record)
            guard let response = response, let status = helpers.toStatus(response.action) else {
                return nil
            }
            let event = AgeGateEvent(status, data.nickname, response)
            let runAgeGateActions: [AgeGateAction] = [.Consent, .IdentityVerify, .AgeVerify]
            guard runAgeGateActions.contains(response.action) else { return event }
            let newEvent = await runAgeGate(data, prevEvent: event, recheckRequired: nil)
            return newEvent
        } catch is CustomServerErrorResponse {
            _ = await permissionService.checkCameraPermission()
            let newEvent = await runAgeGate(data, prevEvent: nil, recheckRequired: .AgeEstimationRequired)
            return newEvent
        } catch _ {
            print("Unexpected issue in \(#function)\(#line)")
            return nil
        }
    }
    
    func recheckAgeGateByBirthDay(_ data: CheckAgeData) async -> AgeGateEvent? {
        guard let agId = storage.getStoredAgeGateId(userIdentifier: data.userIdentifier, nickname: data.nickname) else { return nil }
        let record = RecheckStatusRecord(PrivoService.settings.serviceIdentifier, agId, data)
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
        } catch _ {
            print("Unexpected issue in \(#function)\(#line)")
            return nil
        }
    }
    
    func runAgeGate(_ data: CheckAgeData,
                    prevEvent: AgeGateEvent?,
                    recheckRequired: AgeGateInternalAction?) async -> AgeGateEvent? {
        guard let state = await getAgeGateState(userIdentifier: data.userIdentifier, niсkname: data.nickname) else { return nil }
        let redirectUrl = PrivoService.configuration.ageGatePublicUrl.withPath("/index.html#/age-gate-loading")!.absoluteString
        let ageGateData = CheckAgeStoreData(serviceIdentifier: PrivoService.settings.serviceIdentifier,
                                            state: state,
                                            data: data,
                                            redirectUrl: redirectUrl)
        let targetPage = helpers.getStatusTargetPage(prevEvent?.status, recheckRequired: recheckRequired)
        let result: AgeGateEvent? = await withCheckedContinuation { @MainActor promise in
           UIApplication.shared.showView(false, content: {
               PrivoAgeGateView(ageGateData: ageGateData,
                           targetPage: targetPage,
                           onFinish: { [weak self] events in
                   guard let self = self, !events.isEmpty else { promise.resume(returning: nil); return }
                   for e in events {
                       if (e.status == .IdentityVerified || e.status == .AgeVerified) {
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
            let ageGateData = CheckAgeStoreData(serviceIdentifier: PrivoService.settings.serviceIdentifier,
                                                settings: settings,
                                                userIdentifier: userIdentifier,
                                                nickname: nickname,
                                                countryCode: nil,
                                                birthDateYYYYMMDD: nil,
                                                birthDateYYYYMM: nil,
                                                birthDateYYYY: nil,
                                                redirectUrl: nil,
                                                agId: agId,
                                                fpId: fpId,
                                                age: nil)
            await UIApplication.shared.showView(false) {
                PrivoAgeGateView(ageGateData : ageGateData,
                            targetPage: "age-gate-identifier",
                            finishCriteria: "identifier-closed",
                            onFinish: { [weak self]  _ in
                    await self?.hide()
                })
            }
        } catch _ {
            print("Unexpected issue in \(#function)\(#line)")
        }
    }
    
    @MainActor
    func hide() async {
        UIApplication.shared.dismissTopView()
    }
    
}
