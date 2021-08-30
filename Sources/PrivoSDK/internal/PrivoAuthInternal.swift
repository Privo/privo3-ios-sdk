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
    private let accessIdKey = "accessId"
    public init(isPresented: Binding<Bool>, onFinish: ((String?) -> Void)? = nil, closeIcon: Image? = nil) {
        self._isPresented = isPresented
        self.closeIcon = closeIcon
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
                    self.onFinish?(token)
                }
            } else {
                self.onFinish?(nil)
            }
            
        })
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

