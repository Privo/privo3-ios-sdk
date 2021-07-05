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
    // private let uiHelper = WebViewUIHelper()

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
        // webview.uiDelegate = uiHelper
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
    
    class WebViewNavigationHelper: NSObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {
        var finishCriteria: String?
        var onFinish: ((String) -> Void)?
        
        private var lastFileDestinationURL: URL?
        
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
                if (mimeType.lowercased().contains("pdf")) {
                    if #available(iOS 14.5, *) {
                        decisionHandler(.download)
                    } else {
                        decisionHandler(.cancel)
                    }
                    return
                }
            }
            decisionHandler(.allow)
        }
        @available(iOS 14.5, *)
        public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
            download.delegate = self
        }
        @available(iOS 14.5, *)
        public func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
            let temporaryDir = NSTemporaryDirectory()
            let fileName = temporaryDir + "/" + suggestedFilename
            let url = URL(fileURLWithPath: fileName)
            lastFileDestinationURL = url
            completionHandler(url)
        }

        @available(iOS 14.5, *)
        public func downloadDidFinish(_ download: WKDownload) {
            if let url = lastFileDestinationURL {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                UIApplication.shared.topMostViewController()?.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    /*
    class WebViewUIHelper: NSObject,  WKUIDelegate {
        var pdfCriteria: String?
        var pdfName: String?
        //private let loadingHelper = WebViewLoadingHelper()

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil{
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
            }
            return nil
        }
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
         
    }
 */
}


