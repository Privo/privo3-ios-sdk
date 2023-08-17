import UIKit
import JWTDecode

public class PrivoAuthManager {
    
    //MARK: - Private properties
    
    private let application: UIApplication
    private let userDefaults: UserDefaults
    private let api: Rest
    
    //MARK: - Public initialisers
    
    public init(application: UIApplication = .shared, userDefaults: UserDefaults = .standard) {
        self.application = application
        self.userDefaults = userDefaults
        self.api = .shared
    }
    
    public struct AuthDialog {
        fileprivate init() {}
        public func hide() { UIApplication.shared.dismissTopView() }
    }
    
    //MARK: - Public functions
    
    public func showRegister(_ completion: ((AuthDialog) -> Void)?) {
        Task.init(priority: .userInitiated) { @MainActor in
            let authDialog = AuthDialog()
            application.showView(false) {
                PrivoRegisterStateView(onClose: {
                    authDialog.hide()
                }) {
                    completion?(authDialog)
                }
            }
        }
    }
    
    public func showAuth(_ completion: ((String?) -> Void)?) {
        Task.init(priority: .userInitiated) { @MainActor in
            let authDialog = AuthDialog()
            application.showView(false) {
                PrivoAuthStateView(onClose: {
                    authDialog.hide()
                }, onFinish: { r in
                    authDialog.hide()
                    completion?(r)
                })
            }
        }
    }
    
    public func getToken() -> String? {
        if let token = userDefaults.string(forKey: PrivoService.configuration.tokenStorageKey) {
            if let jwt = try? decode(jwt: token) {
                if let exp = jwt.expiresAt {
                    if exp > Date() {
                        return token
                    }
                } else {
                    return token
                }
            }
        }
        logout()
        return nil
    }
    
    public func renewToken(completionHandler: @escaping (TokenStatus?) -> Void) {
        Task.init(priority: .userInitiated) {
            guard let oldToken = getToken() else {
                completionHandler(nil)
                return
            }
            guard let sessionId = await api.getAuthSessionId() else {
                completionHandler(nil)
                return
            }
            guard let newToken = await api.renewToken(oldToken: oldToken, sessionId: sessionId) else {
                completionHandler(.init(token: oldToken, isRenewed: false))
                return
            }
            userDefaults.set(newToken, forKey: PrivoService.configuration.tokenStorageKey)
            completionHandler(.init(token: newToken, isRenewed: true))
        }
    }
    
    public func logout() -> Void {
        userDefaults.removeObject(forKey: PrivoService.configuration.tokenStorageKey)
    }
    
}
