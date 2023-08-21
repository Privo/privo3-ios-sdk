//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 01.06.2021.
//

import SwiftUI
import JWTDecode

public struct PrivoAuthButton<Label> : View where Label : View {
    
    //MARK: - Internal properties
    
    @State var isPresented = false
    let label: Label
    var closeIcon: Image?
    let onFinish: ((String?) -> Void)?
    
    //MARK: - Private properties
    
    private let accessIdKey = "accessId"
    
    //MARK: - Public initialisers
    
    public init(@ViewBuilder label: () -> Label,
                onFinish: ((String?) -> Void)? = nil,
                closeIcon: (() -> Image)? = nil) {
        self.label = label()
        self.closeIcon = closeIcon?()
        self.onFinish = onFinish
    }
    
    //MARK: - Body builder
    
    public var body: some View {
        return Button {
            isPresented = true
        } label: {
            label
        }.sheet(isPresented: $isPresented) {
            PrivoAuthView(isPresented: $isPresented, onFinish: { r in
                isPresented = false
                onFinish?(r)
            }, closeIcon: closeIcon)
        }
    }
}

public struct PrivoRegisterButton<Label> : View where Label : View {
    
    //MARK: - Internal properties
    
    @Binding var isPresented: Bool
    let label: Label
    var closeIcon: Image?
    let onFinish: (() -> Void)?
    
    //MARK: - Public initialisers
    
    public init(isPresented: Binding<Bool>,
                @ViewBuilder label: () -> Label,
                onFinish: (() -> Void)? = nil,
                closeIcon: (() -> Image)? = nil ) {
        self.label = label()
        self.closeIcon = closeIcon?()
        self._isPresented = isPresented
        self.onFinish = onFinish
    }
    
    //MARK: - Body builder
    
    public var body: some View {
        return Button {
            isPresented = true
        } label: {
            label
        }.sheet(isPresented: $isPresented) {
            PrivoRegisterView(isPresented: $isPresented, onFinish: onFinish, closeIcon: closeIcon)
        }
    }
}

public class PrivoAuth {
    
    public struct AuthDialog {
        fileprivate init() {}
        public func hide() { UIApplication.shared.dismissTopView() }
    }
    
    //MARK: - Private properties
    
    private let app: UIApplication
    private let userDefaults: UserDefaults
    private let api: Rest
    
    //MARK: - Public initialisers
    
    public init(app: UIApplication = .shared, userDefaults: UserDefaults = .standard) {
        self.app = app
        self.userDefaults = userDefaults
        self.api = .shared
    }
    
    //MARK: - Public functions
    
    public func showRegister(_ completion: ((AuthDialog) -> Void)?) {
        Task.init(priority: .userInitiated) { @MainActor in
            let authDialog = AuthDialog()
            app.showView(false) {
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
            app.showView(false) {
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
        if let token = userDefaults.string(forKey: PrivoInternal.configuration.tokenStorageKey) {
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
            userDefaults.set(newToken, forKey: PrivoInternal.configuration.tokenStorageKey)
            completionHandler(.init(token: newToken, isRenewed: true))
        }
    }
    
    public func logout() -> Void {
        userDefaults.removeObject(forKey: PrivoInternal.configuration.tokenStorageKey)
    }
    
}
