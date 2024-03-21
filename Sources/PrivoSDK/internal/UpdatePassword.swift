import SwiftUI

@MainActor
class UpdatePassword: ObservableObject {
    
    @Published
    var config: WebviewConfig
    
    @Published
    var isPresented: Bool = true

    @Published
    var isFailedContent: Bool = false
    
    let url: URL
    let onClose: (() -> Void)
    let onFinish: (() -> Void)?
    
    init(url url_: URL,
         onClose: @escaping () -> Void,
         onFinish: (() -> Void)? = nil) {
        // It's even better to add &mode=SIMPLE to the URL to hide the potential header and footer.
        self.url = url_.withQueryParam(name: "mode", value: "SIMPLE")
        self.onFinish = onFinish
        self.onClose = onClose
        self.config = WebviewConfig(url: url,
            closeIcon: nil,
            showCloseIcon: false,
            scriptUrlTrigger: "about:blank",
            script: "document.querySelector(\"[ng-show='step == steps.COMPLETE']\").classList.contains(\"ng-hide\")",
            onFinish: { _ in onFinish?() },
            onClose: onClose
        )
        config.onFailedContent = { [weak self] in
            self?.isFailedContent = true
        }
    }
}
