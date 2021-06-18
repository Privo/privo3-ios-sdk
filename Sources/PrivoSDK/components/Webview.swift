import SwiftUI
import WebKit

struct WebviewConfig {
    let url: URL
    var closeIcon: Image?
    var showCloseIcon = true
    var finishCriteria: String?
    var onPrivoEvent: (([String : AnyObject]?) -> Void)?;
    var onFinish: ((String) -> Void)?
}

struct Webview: UIViewRepresentable {
    
    let config: WebviewConfig
    private let navigationHelper = WebViewNavigationHelper()

    func makeUIView(context: UIViewRepresentableContext<Webview>) -> WKWebView {
        let webview = WKWebView()
        webview.isOpaque = false
        webview.backgroundColor = .clear
        webview.scrollView.backgroundColor = .clear
        if let finishCriteria = config.finishCriteria,
           let onFinish = config.onFinish {
            navigationHelper.finishCriteria = finishCriteria
            navigationHelper.onFinish = onFinish
            webview.navigationDelegate = navigationHelper
        }
        if let onPrivoEvent = config.onPrivoEvent {
            let contentController = ContentController(onPrivoEvent)
            webview.configuration.userContentController.add(contentController, name: "privo")
        }
        let request = URLRequest(url: config.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
        return webview
    }

    func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<Webview>) {
        let request = URLRequest(url: config.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
    }
    
    class ContentController: WKUserContentController, WKScriptMessageHandler {
        let onPrivoEvent: (([String : AnyObject]?) -> Void)?
        init(_ onPrivoEvent: @escaping ([String : AnyObject]?) -> Void) {
            self.onPrivoEvent = onPrivoEvent
            super.init()
        }
        
        required init?(coder: NSCoder) {
            onPrivoEvent = nil
            super.init(coder: coder)
        }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let dict = message.body as? [String : AnyObject] else {
                onPrivoEvent?(nil)
                return
            }
            onPrivoEvent?(dict)
            
        }
    }
    
    class WebViewNavigationHelper: NSObject, WKNavigationDelegate {
        var finishCriteria: String?
        var onFinish: ((String) -> Void)?
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
            print("!!!!!!!!!!!!!!TEST!!!")
            if let url = navigationAction.request.url?.absoluteString,
               let finishCriteria = finishCriteria,
               let onFinish = onFinish {
                if  url.contains(finishCriteria) {
                    onFinish(url)
                }
            }
        }
    }
}

