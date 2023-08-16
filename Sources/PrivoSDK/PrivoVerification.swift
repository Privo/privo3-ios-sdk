import UIKit

public class PrivoVerification {
    
    //MARK: - Private propertries
    
    private let verification = InternalPrivoVerification()
    
    //MARK: - Public initialisers
    
    public init() {}
    
    //MARK: - Public functions
    
    public func showVerification(_ profile: UserVerificationProfile?, completion: ((Array<VerificationEvent>) -> Void)?) {
        Task.init(priority: .userInitiated) { @MainActor in
            UIApplication.shared.showView(true) {
                VerificationStateView(profile: profile,
                                      onClose: { UIApplication.shared.dismissTopView() }) { e in
                    UIApplication.shared.dismissTopView()
                    completion?(e)
                }
            }
        }
    }
}
