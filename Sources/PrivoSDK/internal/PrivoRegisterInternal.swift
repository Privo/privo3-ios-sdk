//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 30.08.2021.
//

import SwiftUI


struct PrivoRegisterView: View {
    @Binding var isPresented: Bool
    @State var config: WebviewConfig?
    var closeIcon: Image?
    let onFinish: (() -> Void)?
    private let siteIdKey = "siteId"
    public init(isPresented: Binding<Bool>, onFinish: (() -> Void)? = nil, closeIcon: Image? = nil ) {
        self.closeIcon = closeIcon
        self._isPresented = isPresented
        self.onFinish = onFinish
    }
    func setConfig(_ siteId: Int) {
        let url = PrivoInternal.configuration.lgsRegistrationUrl.withQueryParam(name: siteIdKey, value: String(siteId))!
        config = WebviewConfig(url: url, closeIcon: closeIcon, finishCriteria: "step=complete", onFinish: { _ in
            onFinish?()
        })
    }
    func showView() {
        let serviceIdentifier = PrivoInternal.settings.serviceIdentifier
        PrivoInternal.rest.getServiceInfo(serviceIdentifier: serviceIdentifier) { serviceInfo in
            if let siteId = serviceInfo?.p2siteId {
                setConfig(siteId)
            }
        }
    }
    public var body: some View {
        VStack {
            if config != nil {
                ModalWebView(isPresented: self.$isPresented, config: config!)
            }
        }.onAppear {
            showView()
        }
    }
}

struct PrivoRegisterStateView : View {
    @State var isPresented: Bool = true
    let onClose: (() -> Void)
    let onFinish: (() -> Void)?
    public var body: some View {
        PrivoRegisterView(isPresented: self.$isPresented.onChange({ presented in
            if (presented == false) {
                onClose()
            }
        }), onFinish: onFinish)
    }
}
