import UIKit

public class PrivoVerificationManager {
    
    //MARK: - Private properties
    
    private let verification: PrivoVerificationService
    private let application: UIApplication
    
    //MARK: - Public initialisers
    
    public init(application: UIApplication = .shared) {
        self.verification = .init()
        self.application = application
    }
    
    //MARK: - Public functions
    
    public func showVerification(_ profile: UserVerificationProfile?,
                                 completion: ((Array<VerificationEvent>) -> Void)?) {
        Task.init(priority: .userInitiated) { @MainActor in
            application.showView(true) {
                PrivoVerificationStateView(profile: profile,
                                           onClose: { [weak self] in self?.application.dismissTopView() }) { e in
                    self.application.dismissTopView()
                    completion?(e)
                }
            }
        }
    }
}
