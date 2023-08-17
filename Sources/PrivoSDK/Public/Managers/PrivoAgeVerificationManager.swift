import Foundation

public class PrivoAgeVerificationManager {
    
    //MARK: - Private properties
    
    private let ageVerification: PrivoAgeVerificationService
    
    //MARK: - Public initialisers

    public init() {
        ageVerification = .init()
    }
    
    //MARK: - Public functions
    
    public func getStatus(_ userIdentifier: String? = nil, completionHandler: @escaping (AgeVerificationEvent) -> Void) {
        Task.init(priority: .userInitiated) {
            let event = await ageVerification.getLastEvent(userIdentifier)
            completionHandler(event)
        }
    }
    
    public func run(_ profile: AgeVerificationProfile?, completionHandler: @escaping (AgeVerificationEvent?) -> Void) {
        Task.init {
            let event = await ageVerification.getLastEvent(profile?.userIdentifier)
            if (event.status != .Undefined && event.status != .Canceled) {
                completionHandler(event)
            } else {
                ageVerification.runAgeVerification(profile) { [weak self] event in
                    self?.ageVerification.saveVerificationIdentifier(userIdentifier: profile?.userIdentifier, verificationIdentifier: event?.ageVerificationId)
                    let publicEvent = event?.toEvent
                    completionHandler(publicEvent)
                }
            }
        }
    }
    
    public func hide() {
        ageVerification.hide()
    }
    
}
