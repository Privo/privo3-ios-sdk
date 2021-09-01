//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 01.06.2021.
//

import SwiftUI
import JWTDecode

public struct PrivoAuthButton<Label> : View where Label : View {
    @State var isPresented = false
    let label: Label
    var closeIcon: Image?
    let onFinish: ((String?) -> Void)?
    private let accessIdKey = "accessId"
    public init(@ViewBuilder label: () -> Label, onFinish: ((String?) -> Void)? = nil, closeIcon: (() -> Image)? = nil) {
        self.label = label()
        self.closeIcon = closeIcon?()
        self.onFinish = onFinish
    }
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
    @Binding var isPresented: Bool
    let label: Label
    var closeIcon: Image?
    let onFinish: (() -> Void)?
    public init(isPresented: Binding<Bool>, @ViewBuilder label: () -> Label, onFinish: (() -> Void)? = nil, closeIcon: (() -> Image)? = nil ) {
        self.label = label()
        self.closeIcon = closeIcon?()
        self._isPresented = isPresented
        self.onFinish = onFinish
    }
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
    public init() {}
    public struct AuthDialog {
        fileprivate init() {}
        public func hide() { UIApplication.shared.dismissTopView() }
    }
    
    public func showRegister(_ completion: ((AuthDialog) -> Void)?) {
        let authDialog = AuthDialog()
        UIApplication.shared.showView(false) {
            PrivoRegisterStateView(onClose: {
                authDialog.hide()
            }) {
                completion?(authDialog)
            }
        }
    }
    public func showAuth(_ completion: ((String?) -> Void)?) {
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
        if let oldToken = getToken() {
            PrivoInternal.rest.getAuthSessionId { sessionId in
                if let sessionId = sessionId {
                    PrivoInternal.rest.renewToken(oldToken: oldToken, sessionId: sessionId) { token in
                        if let token = token {
                            UserDefaults.standard.set(token, forKey: PrivoInternal.configuration.tokenStorageKey)
                            completionHandler(TokenStatus(token: token, isRenewed: true))
                        } else {
                            completionHandler(TokenStatus(token: oldToken, isRenewed: false))
                        }
                    }
                } else {
                    completionHandler(nil)
                }
            }
        } else {
            completionHandler(nil)
        }
    }
    public func logout() -> Void {
        UserDefaults.standard.removeObject(forKey: PrivoInternal.configuration.tokenStorageKey)
    }
}
