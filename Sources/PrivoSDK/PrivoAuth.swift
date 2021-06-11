//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 01.06.2021.
//

import SwiftUI
import JWTDecode

struct ModalWebView: View {
  @Binding var isPresented: Bool
  let url: URL
  var closeIcon: Image?
  let onPrivoEvent: ([String : AnyObject]?) -> Void;
  
  var body: some View {
    return VStack() {
        HStack() {
            Spacer()
            Button(action: {
              isPresented = false
            }, label: {
                if (self.closeIcon != nil) {
                    self.closeIcon
                } else {
                    Image(systemName: "xmark").font(.system(size: 20.0, weight: .bold)).foregroundColor(.black).padding(5)
                }
            })
        }
        Webview(url: url, onPrivoEvent: {data in
            self.onPrivoEvent(data)
            isPresented = false
        }).KeyboardAwarePadding()
    }
  }
}

public struct PrivoAuthView<Label> : View where Label : View {
    @State var presentingAuth = false
    let label: Label
    var closeIcon: Image?
    let onFinish: ((String?) -> Void)?
    private let accessIdKey = "accessId"
    public init(@ViewBuilder label: () -> Label, onFinish: ((String?) -> Void)? = nil, closeIcon: Image? = nil ) {
        self.label = label()
        self.onFinish = onFinish
        self.closeIcon = closeIcon
    }
    public var body: some View {
        // let serviceIdentifier = PrivoInternal.shared.settings.serviceIdentifier; // Uncomment it later when Alex fix a backend
        let url = PrivoInternal.shared.configuration.authStartUrl
        // url.appendQueryParam(name: "service_identifier", value: serviceIdentifier) // Uncomment it later when Alex fix a backend
        return Button {
            presentingAuth = true
        } label: {
            label
        }.sheet(isPresented: $presentingAuth) {
            ModalWebView(isPresented: self.$presentingAuth,  url: url, onPrivoEvent: { event in
                if let accessId = event?[accessIdKey] as? String {
                    PrivoInternal.shared.rest.getValueFromTMPStorage(key: accessId) { resp in
                        let token = resp?.data
                        if (token != nil) {
                            UserDefaults.standard.set(token, forKey: PrivoInternal.shared.configuration.tokenStorageKey)
                        }
                        self.onFinish?(token)
                    }
                } else {
                    self.onFinish?(nil)
                }
            })
        }
    }
}

public struct PrivoRegisterView<Label> : View where Label : View {
    @State var presentingRegister = false
    let label: Label
    var closeIcon: Image?
    let onFinish: (() -> Void)?
    private let siteIdKey = "siteId"
    public init(@ViewBuilder label: () -> Label, onFinish: (() -> Void)? = nil, closeIcon: Image? = nil ) {
        self.label = label()
        self.onFinish = onFinish
        self.closeIcon = closeIcon
    }
    public var body: some View {
        let siteId = PrivoInternal.shared.settings.siteId;
        var url = PrivoInternal.shared.configuration.lgsRegistrationUrl
        if let siteId = siteId {
            url.appendQueryParam(name: siteIdKey, value: siteId)
        }
        return Button {
            presentingRegister = true
        } label: {
            label
        }.sheet(isPresented: $presentingRegister) {
            ModalWebView(isPresented: self.$presentingRegister, url: url, onPrivoEvent: {_ in
                self.onFinish?()
            })
        }
    }
}

public class PrivoAuth {
    public init() {}
    public func getToken() -> String? {
        if let token = UserDefaults.standard.string(forKey: PrivoInternal.shared.configuration.tokenStorageKey) {
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
            PrivoInternal.shared.rest.getAuthSessionId { sessionId in
                if let sessionId = sessionId {
                    PrivoInternal.shared.rest.renewToken(oldToken: oldToken, sessionId: sessionId) { token in
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
        UserDefaults.standard.removeObject(forKey: PrivoInternal.shared.configuration.tokenStorageKey)
    }
}
