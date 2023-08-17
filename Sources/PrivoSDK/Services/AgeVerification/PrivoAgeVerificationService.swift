import Foundation
import SwiftUI

class PrivoAgeVerificationService {
    
    //MARK: - Private properties
    
    private let AGE_VERIFICATION_EVENT_KEY = "AgeVerificationEvent"
    private let PRIVO_STATE_ID = "privo_state_id";
    
    private let keychain: PrivoKeychain
    private let api: Rest
    
    //MARK: - Internal initialisers
    
    init(keychain: PrivoKeychain = .init(), api: Rest = .shared) {
        self.keychain = keychain
        self.api = api
    }
    
    //MARK: - Internal functions
     
    func toInternalEvent(_ from: AgeVerificationResponse, userIdentifier: String?) -> AgeVerificationEventInternal {
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
    
    func getLastEvent(_ userIdentifier: String?, completionHandler: @escaping (AgeVerificationEvent) -> Void ) {
       let key = "\(AGE_VERIFICATION_EVENT_KEY)-\(userIdentifier ?? "")"
        guard let verificationIdentifier = keychain.get(key) else {
            completionHandler(.init(status: .Undefined, profile: nil))
            return
        }
        api.getAgeVerification(verificationIdentifier: verificationIdentifier) { [weak self] verification in
            guard let verification = verification,
                  let event = self?.toInternalEvent(verification,userIdentifier: userIdentifier).toEvent else {
                completionHandler(.init(status: .Undefined, profile: nil))
                return
            }
            completionHandler(event)
        }
    }
    
    func getLastEvent(_ userIdentifier: String?) async -> AgeVerificationEvent {
        let key = "\(AGE_VERIFICATION_EVENT_KEY)-\(userIdentifier ?? "")"
        guard let verificationIdentifier = keychain.get(key) else { return .init(status: .Undefined, profile: nil) }
        let verification = await api.getAgeVerification(verificationIdentifier: verificationIdentifier)
        guard let verification = verification,
              let event = toInternalEvent(verification, userIdentifier: userIdentifier).toEvent else {
            return .init(status: .Undefined, profile: nil)
        }
        return event
    }
    
    func runAgeVerification(_ profile: AgeVerificationProfile?, completionHandler: @escaping (AgeVerificationEventInternal?) -> Void) {
        let redirectUrl = PrivoService.configuration.ageVerificationPublicUrl.withPath("/index.html#/age-verification-loading")!.absoluteString
        let ageVerificationData = AgeVerificationStoreData(serviceIdentifier:PrivoService.settings.serviceIdentifier,
                                                           redirectUrl: redirectUrl,
                                                           profile: profile)
        UIApplication.shared.showView(false) {
            PrivoAgeVerificationView(ageVerificationData : ageVerificationData,
                onFinish: { events in
                    let nonCanceledEvents = events.filter { $0.status != .Canceled && $0.status != .Closed }
                    let publicEvents = nonCanceledEvents.isEmpty ? events : nonCanceledEvents
                    publicEvents.forEach { event in
                        completionHandler(event)
                    }
                    if publicEvents.isEmpty {
                        completionHandler(nil)
                    }
                    UIApplication.shared.dismissTopView()
            })
        }
    }
    
    func hide() {
        UIApplication.shared.dismissTopView()
    }
    
}
