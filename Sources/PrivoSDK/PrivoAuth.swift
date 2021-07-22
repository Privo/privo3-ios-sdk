//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 01.06.2021.
//

import SwiftUI
import JWTDecode

public struct PrivoAuthButton<Label> : View where Label : View {
    @State var presentingAuth = false
    let label: Label
    var closeIcon: Image?
    let onFinish: ((String?) -> Void)?
    private let accessIdKey = "accessId"
    public init(@ViewBuilder label: () -> Label, onFinish: ((String?) -> Void)? = nil, closeIcon: (() -> Image)? = nil) {
        self.label = label()
        self.closeIcon = closeIcon?()
        self.onFinish = onFinish
    }
    func getConfig() -> WebviewConfig {
        // let serviceIdentifier = PrivoInternal.shared.settings.serviceIdentifier; // Uncomment it later when Alex fix a backend
        let url = PrivoInternal.configuration.authStartUrl
        // url.appendQueryParam(name: "service_identifier", value: serviceIdentifier) // Uncomment it later when Alex fix a backend
        return WebviewConfig(url: url, closeIcon: closeIcon, onPrivoEvent: { event in
            if let accessId = event?[accessIdKey] as? String {
                PrivoInternal.rest.getValueFromTMPStorage(key: accessId) { resp in
                    let token = resp?.data
                    if (token != nil) {
                        UserDefaults.standard.set(token, forKey: PrivoInternal.configuration.tokenStorageKey)
                    }
                    presentingAuth = false
                    self.onFinish?(token)
                }
            } else {
                presentingAuth = false
                self.onFinish?(nil)
            }
            
        })
    }
    public var body: some View {
        
        return Button {
            presentingAuth = true
        } label: {
            label
        }.sheet(isPresented: $presentingAuth) {
            ModalWebView(isPresented: self.$presentingAuth,  config: getConfig())
        }
    }
}

public struct PrivoRegisterButton<Label> : View where Label : View {
    @Binding var presentingRegister: Bool
    let label: Label
    var closeIcon: Image?
    let onFinish: (() -> Void)?
    private let siteIdKey = "siteId"
    public init(isPresented: Binding<Bool>, @ViewBuilder label: () -> Label, onFinish: (() -> Void)? = nil, closeIcon: (() -> Image)? = nil ) {
        self.label = label()
        self.closeIcon = closeIcon?()
        self._presentingRegister = isPresented
        self.onFinish = onFinish
    }
    func getConfig() -> WebviewConfig {
        let siteId = "1"; // TMP, replace it with exchanged serviceIdentifier later (if we are going to use this view)
        let url = PrivoInternal.configuration.lgsRegistrationUrl.withQueryParam(name: siteIdKey, value: siteId)!
        return WebviewConfig(url: url, closeIcon: closeIcon, finishCriteria: "step=complete", onFinish: { _ in
            onFinish?()
        })
    }
    public var body: some View {
        return Button {
            presentingRegister = true
        } label: {
            label
        }.sheet(isPresented: $presentingRegister) {
            ModalWebView(isPresented: self.$presentingRegister, config: getConfig())
        }
    }
}

public class PrivoAuth {
    public init() {}
    public func getToken() -> String? {
        if let token = UserDefaults.standard.string(forKey: PrivoInternal.configuration.tokenStorageKey) {
            if let jwt = try? decode(jwt: token) {
                if let exp = jwt.expiresAt {
                    if exp > Date() {
                        return token
                    }
                }
            }
        }
        cleanToken()
        return nil
    }
    public func checkTokenValid(completionHandler: @escaping (TokenValidity?) -> Void) {
        if let oldToken = getToken() {
            PrivoInternal.rest.getAuthSessionId { sessionId in
                if let sessionId = sessionId {
                    PrivoInternal.rest.renewToken(oldToken: oldToken, sessionId: sessionId) { token in
                        if let token = token {
                            completionHandler(TokenValidity(token: token, isValid: true))
                        } else {
                            completionHandler(TokenValidity(token: oldToken, isValid: false))
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
    public func cleanToken() -> Void {
        UserDefaults.standard.removeObject(forKey: PrivoInternal.configuration.tokenStorageKey)
    }
}
