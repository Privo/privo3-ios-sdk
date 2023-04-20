//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 30.08.2021.
//

import SwiftUI

struct PrivoAuthView: View {
    @Binding var isPresented: Bool
    var closeIcon: Image?
    let onFinish: ((String?) -> Void)?
    private let accessIdKey = "access_id"
    public init(isPresented: Binding<Bool>, onFinish: ((String?) -> Void)? = nil, closeIcon: Image? = nil) {
        self._isPresented = isPresented
        self.closeIcon = closeIcon
        self.onFinish = onFinish
    }
    func getConfig() -> WebviewConfig {
        let serviceIdentifier = PrivoInternal.settings.serviceIdentifier;
        var urlComponents = URLComponents(url: PrivoInternal.configuration.authStartUrl, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems?.append(URLQueryItem(name: "service_identifier", value: serviceIdentifier))
        let url = urlComponents?.url ?? PrivoInternal.configuration.authStartUrl
        return WebviewConfig(
            url: url,
            closeIcon: closeIcon,
            finishCriteria: accessIdKey,
            onFinish: { url in
                if let items = URLComponents(string: url)?.queryItems,
                   let accessId = items.first(where: {$0.name == accessIdKey})?.value {
                    PrivoInternal.rest.getValueFromTMPStorage(key: accessId) { resp in
                        let token = resp?.data
                        if (token != nil) {
                            UserDefaults.standard.set(token, forKey: PrivoInternal.configuration.tokenStorageKey)
                        }
                        self.onFinish?(token)
                    }
                } else {
                    self.onFinish?(nil)
                }
            }
        )
    }
    public var body: some View {
        ModalWebView(isPresented: self.$isPresented, config: getConfig())
    }
}

struct PrivoAuthStateView : View {
    @State var isPresented: Bool = true
    let onClose: (() -> Void)
    let onFinish: ((String?) -> Void)?

    public var body: some View {
        PrivoAuthView(isPresented: self.$isPresented.onChange({ presented in
            if (presented == false) {
                onClose()
            }
        }), onFinish: { r in
            isPresented = false
            onFinish?(r)
        })
    }
}

