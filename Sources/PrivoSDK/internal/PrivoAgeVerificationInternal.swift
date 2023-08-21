//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 13.06.2022.
//

import Foundation
import SwiftUI

internal class PrivoAgeVerificationInternal {
    
    //MARK: - Private properties
    
    private let AGE_VERIFICATION_EVENT_KEY = "AgeVerificationEvent"
    private let PRIVO_STATE_ID = "privo_state_id";
    
    private let keychain: PrivoKeychain
    private let api: Rest
    private let app: UIApplication
    
    //MARK: - Internal initialisers
    
    init(app: UIApplication = .shared, keychain: PrivoKeychain = .init(), api: Rest = .shared) {
        self.app = app
        self.keychain = keychain
        self.api = api
    }
     
    //MARK: - Internal functions
    
    func toInternalEvent(_ from: AgeVerificationTO, userIdentifier: String?) -> AgeVerificationEventInternal {
        let status = from.status;
        let profile = AgeVerificationProfile(userIdentifier: userIdentifier,
                                             firstName: from.firstName,
                                             email: from.email,
                                             birthDateYYYYMMDD: from.birthDate,
                                             phoneNumber: from.mobilePhone)
        return .init(status: status,profile: profile, ageVerificationId: from.verificationIdentifier)
    }
    
    func saveVerificationIdentifier(userIdentifier: String?, verificationIdentifier: String?) {
        guard let verificationIdentifier = verificationIdentifier else { return }
        let key = "\(AGE_VERIFICATION_EVENT_KEY)-\(userIdentifier ?? "")"
        keychain.set(key: key, value: verificationIdentifier)
    }
    
    func getLastEvent(_ userIdentifier: String?, completionHandler: @escaping (AgeVerificationEvent) -> Void) {
        Task.init {
            let result = await getLastEvent(userIdentifier)
            completionHandler(result)
        }
    }
    
    func getLastEvent(_ userIdentifier: String?) async -> AgeVerificationEvent {
        let key = "\(AGE_VERIFICATION_EVENT_KEY)-\(userIdentifier ?? "")"
        guard let verificationIdentifier = keychain.get(key) else { return .init(status: .Undefined, profile: nil) }
        let verification = await api.getAgeVerification(verificationIdentifier: verificationIdentifier)
        guard let verification = verification,
              let event = toInternalEvent(verification,userIdentifier: userIdentifier).toEvent else {
            return .init(status: .Undefined, profile: nil)
        }
        return event
    }
    
    func runAgeVerification(_ profile: AgeVerificationProfile?,
                            completionHandler: @escaping (AgeVerificationEventInternal?) -> Void) {
        let redirectUrl = PrivoInternal.configuration.ageVerificationPublicUrl.withPath("/index.html#/age-verification-loading")!.absoluteString
        let ageVerificationData = AgeVerificationStoreData(serviceIdentifier:PrivoInternal.settings.serviceIdentifier,
                                                           redirectUrl: redirectUrl,
                                                           profile: profile)
        app.showView(false) {
            AgeVerificationView(ageVerificationData : ageVerificationData,
                onFinish: { [weak self] events in
                    let nonCanceledEvents = events.filter { $0.status != .Canceled && $0.status != .Closed }
                    let publicEvents = nonCanceledEvents.isEmpty ? events : nonCanceledEvents
                    publicEvents.forEach { event in
                        completionHandler(event)
                    }
                    if publicEvents.isEmpty {
                        completionHandler(nil)
                    }
                    self?.app.dismissTopView()
            })
        }
    }
    
    func hide() {
        app.dismissTopView()
    }
}

struct PrivoAgeVerificationState {
    var isPresented = false
    var inProgress = true
    var privoStateId: String? = nil
}

struct AgeVerificationView : View {
    
    //MARK: - Internal properties
    
    @State
    var state = PrivoAgeVerificationState()
    let ageVerificationData: AgeVerificationStoreData?
    let onFinish: (([AgeVerificationEventInternal]) -> Void)
    
    private let api: Rest = .shared
    
    //MARK: - Body builder
    
    public var body: some View {
        LoadingView(isShowing: $state.inProgress) {
            VStack {
                if (state.privoStateId != nil) {
                    ModalWebView(isPresented: $state.isPresented,  config: getConfig(state.privoStateId!))
                }
            }.onDisappear {
                finishView(nil)
            }
        }.onAppear {
            showView()
        }
    }
    
    //MARK: - Internal functions
    
    func showView() {
        if let ageVerificationData = ageVerificationData {
            state.inProgress = true
            PrivoInternal.rest.addObjectToTMPStorage(value: ageVerificationData) { id in
                if (id != nil) {
                    self.state.isPresented = true
                    self.state.privoStateId = id
                }
                state.inProgress = false
            }
        }
    }
    
    //MARK: - Private functions

    private func getConfig(_ stateId: String) -> WebviewConfig {
        let ageGateUrl = PrivoInternal.configuration.ageVerificationPublicUrl
             .withPath("/index.html")?
             .withQueryParam(name: "privo_state_id", value: stateId)?
             .withQueryParam(name: "service_identifier", value: PrivoInternal.settings.serviceIdentifier)?
             .withPath("#/intro")
        return .init(url: ageGateUrl!,
                     showCloseIcon: false,
                     finishCriteria: "age-verification-loading",
                     onFinish: { url in
                    guard let items = URLComponents(string: url)?.queryItems,
                          let eventId = items.first(where: {$0.name == "privo_age_verification_events_id"})?.value else {
                         finishView(nil)
                         return
                    }
                    state.inProgress = true
                    api.getObjectFromTMPStorage(key: eventId) { (events: Array<AgeVerificationEventInternal>?) in
                         finishView(events)
                    }
                 },
                 onClose: {
                     finishView(nil)
            })
    }
    
    private func finishView(_ events: Array<AgeVerificationEventInternal>?) {
        state.inProgress = false
        state.privoStateId = nil
        guard state.isPresented else { return }
        state.isPresented = false
        onFinish(events ?? [.init(status: .Canceled, profile: nil, ageVerificationId: nil)])
    }
   
}
