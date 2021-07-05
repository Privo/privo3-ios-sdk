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
    private let uiHelper = WebViewUIHelper()

    func makeUIView(context: UIViewRepresentableContext<Webview>) -> WKWebView {
        let wkPreferences = WKPreferences()
        wkPreferences.javaScriptCanOpenWindowsAutomatically = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = wkPreferences
        let webview = WKWebView(frame: .zero, configuration: configuration)
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
        webview.uiDelegate = uiHelper
        let request = URLRequest(url: config.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
        return webview
    }

    
    func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<Webview>) {
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
    
    class WebViewNavigationHelper: NSObject, WKNavigationDelegate, WKUIDelegate {
        var finishCriteria: String?
        var onFinish: ((String) -> Void)?
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
            if let url = navigationAction.request.url?.absoluteString,
               let finishCriteria = finishCriteria,
               let onFinish = onFinish {
                if  url.contains(finishCriteria) {
                    onFinish(url)
                }
            }
        }
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let mimeType = navigationResponse.response.mimeType {
                print(mimeType)
                print(navigationResponse.response)
            }
            decisionHandler(.allow)
        }
    }
    class WebViewUIHelper: NSObject,  WKUIDelegate {
        var pdfCriteria: String?
        var pdfName: String?
        //private let loadingHelper = WebViewLoadingHelper()

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil{
                /*
                if let url = navigationAction.request.url,
                   let pdfCriteria = pdfCriteria {
                    if  url.absoluteString.contains(pdfCriteria) {
                        loadingHelper.pdfName = pdfName
                        let newWebView = WKWebView(frame: webView.bounds, configuration: configuration)
                        newWebView.isHidden = true
                        newWebView.navigationDelegate = loadingHelper
                        webView.addSubview(newWebView)
                        newWebView.load(navigationAction.request)
                    }
                }
 */
            }
            return nil
        }
        /*
        class WebViewLoadingHelper: NSObject, WKNavigationDelegate {
            var pdfName: String?
            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    if let pdfFilePath = webView.exportAsPdfFromWebView(name: self?.pdfName ?? "privo.pdf") {
                        webView.removeFromSuperview()
                        let activityViewController = UIActivityViewController(activityItems: [pdfFilePath], applicationActivities: nil)
                        UIApplication.shared.topMostViewController()?.present(activityViewController, animated: true, completion: nil)
                    }
                }
            }
        }
         */
    }
}


