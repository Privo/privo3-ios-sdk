//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 30.08.2021.
//

import SwiftUI

struct PrivoAuthView: View {
    
    //MARK: - Internal properties
    
    @Binding
    var isPresented: Bool
    var closeIcon: Image?
    let onFinish: ((String?) -> Void)?
    
    //MARK: - Private properties
    
    private let accessIdKey = "access_id"
    private let userDefaults: UserDefaults
    private let api: Rest
    
    //MARK: - Public initialisers
    
    public init(isPresented: Binding<Bool>,
                onFinish: ((String?) -> Void)? = nil,
                closeIcon: Image? = nil,
                api: Rest = .shared,
                userDefaults: UserDefaults = .standard) {
        self._isPresented = isPresented
        self.closeIcon = closeIcon
        self.onFinish = onFinish
        self.api = api
        self.userDefaults = userDefaults
    }
    
    //MARK: - Body builder
    
    public var body: some View {
        ModalWebView(isPresented: self.$isPresented, config: getConfig())
    }
    
    //MARK: - Internal functions
    
    func getConfig() -> WebviewConfig {
        let serviceIdentifier = PrivoInternal.settings.serviceIdentifier
        var url = PrivoInternal.configuration.authBaseUrl
        url.appendPathComponent("authorize")
        var urlComponents = url.urlComponent()
        urlComponents.queryItems = [.init(name: "client_id", value: "mobile"),
                                     .init(name: "service_identifier", value: serviceIdentifier),
                                     .init(name: "redirect_uri", value: "")]
        let resultUrl = urlComponents.url ?? url
        return .init(url: resultUrl, closeIcon: closeIcon, finishCriteria: accessIdKey, onFinish: { url in
            guard let items = URLComponents(string: url)?.queryItems,
                  let accessId = items.first(where: {$0.name == accessIdKey})?.value else {
                onFinish?(nil)
                return
            }
            api.getValueFromTMPStorage(key: accessId) { resp in
                let token = resp?.data
                if token != nil {
                    userDefaults.set(token, forKey: PrivoInternal.configuration.tokenStorageKey)
                }
                onFinish?(token)
            }
        })
    }
    
}

struct PrivoAuthStateView : View {
    
    //MARK: - Internal properties
    
    @State
    var isPresented: Bool = true
    let onClose: (() -> Void)
    let onFinish: ((String?) -> Void)?

    //MARK: - Body builder
    
    public var body: some View {
        PrivoAuthView(isPresented: $isPresented.onChange({ presented in
            guard presented else { return }
            onClose()
        }), onFinish: { r in
            isPresented = false
            onFinish?(r)
        })
    }
    
}

