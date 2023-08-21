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
        let serviceIdentifier = PrivoInternal.settings.serviceIdentifier;
        var urlComponents = URLComponents(url: PrivoInternal.configuration.authStartUrl, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems?.append(URLQueryItem(name: "service_identifier", value: serviceIdentifier))
        let url = urlComponents?.url ?? PrivoInternal.configuration.authStartUrl
        return .init(url: url,
                     closeIcon: closeIcon,
                     finishCriteria: accessIdKey,
                     onFinish: { url in
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

