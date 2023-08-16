import UIKit
import JWTDecode

public class PrivoAuth {
    
    //MARK: - Public initialisers
    
    public init() {}
    
    public struct AuthDialog {
        fileprivate init() {}
        public func hide() { UIApplication.shared.dismissTopView() }
    }
    
    //MARK: - Public functions
    
    public func showRegister(_ completion: ((AuthDialog) -> Void)?) {
        Task.init(priority: .userInitiated) { @MainActor in
            let authDialog = AuthDialog()
            UIApplication.shared.showView(false) {
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
            UIApplication.shared.showView(false) {
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
        if let token = UserDefaults.standard.string(forKey: PrivoInternal.configuration.tokenStorageKey) {
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
            guard let sessionId = await PrivoInternal.rest.getAuthSessionId() else {
                completionHandler(nil)
                return
            }
            guard let newToken = await PrivoInternal.rest.renewToken(oldToken: oldToken, sessionId: sessionId) else {
                completionHandler(.init(token: oldToken, isRenewed: false))
                return
            }
            UserDefaults.standard.set(newToken, forKey: PrivoInternal.configuration.tokenStorageKey)
            completionHandler(.init(token: newToken, isRenewed: true))
        }
    }
    
    public func logout() -> Void {
        UserDefaults.standard.removeObject(forKey: PrivoInternal.configuration.tokenStorageKey)
    }
    
}
