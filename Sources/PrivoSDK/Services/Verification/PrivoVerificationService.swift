import SwiftUI

struct PrivoVerificationService {
    
    //MARK: - Private properties
    
    private let redirectUrl = PrivoService.configuration.verificationUrl.withPath("/#/verification-loading")!.absoluteString
    private let api: Rest
    
    //MARK: - Internal initialisers
    
    init(api: Rest = .shared) {
        self.api = api
    }
    
    //MARK: - Internal functions

    func storeState(profile: UserVerificationProfile?, completion: @escaping (String?) -> Void ) -> Void {
        guard let apiKey = PrivoService.settings.apiKey else { return }
        let data = VerificationData(profile: profile ?? .init(),
                                    config: .init(apiKey: apiKey, siteIdentifier: PrivoService.settings.serviceIdentifier),
                                    redirectUrl: redirectUrl)
        api.addObjectToTMPStorage(value: data, completionHandler: completion)
    }
    
    func getCancelEvents() -> [VerificationEvent] {
        [
            .init(event: .verifyInitialized, result: nil, data: nil, errorCode: nil, errorMessage: nil),
            .init(event: .verifyCancel, result: nil, data: nil, errorCode: nil, errorMessage: nil)
        ]
    }
    
}


