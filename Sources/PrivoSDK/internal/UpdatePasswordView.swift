import SwiftUI

struct UpdatePasswordView: View {
    
    let url: URL
    let onClose: (() -> Void)
    let onFinish: (() -> Void)?
    
    @State
    private var isPresented: Bool = true

    @State
    private var config: WebviewConfig

    private var closeIcon: Image?
    
    public init(url: URL,
                onClose: @escaping () -> Void,
                onFinish: (() -> Void)? = nil) {
        self.url = url
        self.onFinish = onFinish
        self.onClose = onClose
        self._config = State(initialValue: WebviewConfig(url: url,
            closeIcon: closeIcon,
            scriptUrlTrigger: "about:blank",
            script: "document.querySelector(\"[ng-show='step == steps.COMPLETE']\").classList.contains(\"ng-hide\")",
            onFinish: { _ in onFinish?() },
            onClose: { onClose() }
        ))
    }
    
    public var body: some View {
        ModalWebView(isPresented: self.$isPresented, config: config)
    }
}
