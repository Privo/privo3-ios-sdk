//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 13.06.2022.
//

import Foundation
import SwiftUI

internal class PrivoAgeVerificationInternal {
    
    private let AGE_VERIFICATION_EVENT_KEY = "AgeVerificationEvent"
    private let PRIVO_STATE_ID = "privo_state_id";
    
    private let keychain = PrivoKeychain()
     
    internal func toInternalEvent(_ from: AgeVerificationTO, userIdentifier: String?) -> AgeVerificationEventInternal {
        let status = from.status;
        let profile = AgeVerificationProfile(
            userIdentifier: userIdentifier,
            firstName: from.firstName,
            email: from.email,
            birthDateYYYYMMDD: from.birthDate,
            phoneNumber: from.mobilePhone,
            ageGateIdentifier: nil
        )
        return AgeVerificationEventInternal(
            status: status,
            profile: profile,
            ageVerificationId: from.verificationIdentifier
        )
    };
    
    internal func saveVerificationIdentifier(userIdentifier: String?, verificationIdentifier: String?) {
        if let verificationIdentifier = verificationIdentifier {
            let key = "\(AGE_VERIFICATION_EVENT_KEY)-\(userIdentifier ?? "")"
            self.keychain.set(key: key, value: verificationIdentifier)
        }
    };
    
    internal func getLastEvent(_ userIdentifier: String?, completionHandler: @escaping (AgeVerificationEvent) -> Void ) {
       let key = "\(AGE_VERIFICATION_EVENT_KEY)-\(userIdentifier ?? "")"
       if let verificationIdentifier = self.keychain.get(key) {
             PrivoInternal.rest.getAgeVerification(verificationIdentifier: verificationIdentifier) { [weak self] verification in
                 if let verification = verification,
                    let event = self?.toInternalEvent(verification,userIdentifier: userIdentifier).toEvent() {
                     completionHandler(event);
                     return
                  }
             }
       }
        completionHandler(AgeVerificationEvent(status: AgeVerificationStatus.Undefined, profile: nil));
    };
    
    internal func runAgeVerification(
        _ profile: AgeVerificationProfile?,
        completionHandler: @escaping (AgeVerificationEventInternal?) -> Void
    ) {
        
        let ageVerificationData = AgeVerificationStoreData(
            serviceIdentifier:PrivoInternal.settings.serviceIdentifier,
            redirectUrl: PrivoInternal.configuration.ageVerificationPublicUrl.withPath("/index.html#/age-verification-loading")!.absoluteString,
            profile: profile
        )
        UIApplication.shared.showView(false) {
            AgeVerificationView(
                ageVerificationData : ageVerificationData,
                onFinish: { events in
 
                    let nonCanceledEvents = events.filter { $0.status != AgeVerificationStatusInternal.Canceled && $0.status != AgeVerificationStatusInternal.Closed };
                    let publicEvents = nonCanceledEvents.isEmpty ? events : nonCanceledEvents
                    publicEvents.forEach { event in
                        completionHandler(event)
                    }
                    if (publicEvents.isEmpty) {
                        completionHandler(nil)
                    }
                    UIApplication.shared.dismissTopView()
                })
        }
    }
    
    internal func hide() {
        UIApplication.shared.dismissTopView()
    }
}



struct PrivoAgeVerificationState {
    var isPresented = false
    var inProgress = true
    var privoStateId: String? = nil
}


struct AgeVerificationView : View {
    @State var state = PrivoAgeVerificationState()
    let ageVerificationData: AgeVerificationStoreData?
    let onFinish: ((Array<AgeVerificationEventInternal>) -> Void)

    private func getConfig(_ stateId: String) -> WebviewConfig {
        let ageGateUrl = PrivoInternal.configuration.ageVerificationPublicUrl
             .withPath("/index.html")?
             .withQueryParam(name: "privo_state_id", value: stateId)?
             .withPath("#/intro")
         return WebviewConfig(
             url: ageGateUrl!,
             showCloseIcon: false,
             finishCriteria: "age-verification-loading",
             onFinish: { url in
                 if let items = URLComponents(string: url)?.queryItems,
                    let eventId = items.first(where: {$0.name == "privo_age_verification_events_id"})?.value {
                     state.inProgress = true
                     PrivoInternal.rest.getObjectFromTMPStorage(key: eventId) { (events: Array<AgeVerificationEventInternal>?) in
                         finishView(events)
                     }
                 } else {
                     finishView(nil)
                 }
             },
             onClose: {
                 finishView(nil)
             }
         )
    }
    
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
    private func finishView(_ events: Array<AgeVerificationEventInternal>?) {
        state.inProgress = false
        state.privoStateId = nil
        
        if (state.isPresented == true) {
            state.isPresented = false
            onFinish(events ?? [AgeVerificationEventInternal(status: AgeVerificationStatusInternal.Canceled, profile: nil, ageVerificationId: nil)])
        }
    }
    
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
}
