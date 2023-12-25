import SwiftUI
import WebKit

struct WebviewConfig {
    let url: URL
    var closeIcon: Image?
    var showCloseIcon = true
    var printCriteria: String?
    var finishCriteria: String?
    var onPrivoEvent: (([String : AnyObject]?) -> Void)?;
    var onFinish: ((String) -> Void)?
    var onClose: (() -> Void)?
}
class WebViewModel: ObservableObject {
    
    let permissionService: PrivoCameraPermissionServiceType
    
    init(permissionService: PrivoCameraPermissionServiceType) {
        self.permissionService = permissionService
    }
    
}
struct Webview: UIViewRepresentable {
    
    //MARK: - Internal properties
    @Binding
    var isLoading: Bool
    
    let permissionService: PrivoCameraPermissionServiceType
    
    let config: WebviewConfig
    
    /*
    init (config: WebviewConfig) {
        self.config = config
        
        if #available(iOS 14.5, *) {
            self.navigationHelper = WebViewNavigationHelperModern()
        } else {
            self.navigationHelper = WebViewNavigationHelper()
        }
        
    }
     */
    
    func makeCoordinator() -> WebViewCoordinator {
        let coordinator = WebViewCoordinator($isLoading, permissionService)
        coordinator.finishCriteria = config.finishCriteria
        coordinator.onFinish = config.onFinish
        coordinator.printCriteria = config.printCriteria
        coordinator.onFinish = config.onFinish
        return coordinator
    }

    func makeUIView(context: UIViewRepresentableContext<Webview>) -> WKWebView {
        let wkPreferences = WKPreferences()
        wkPreferences.javaScriptCanOpenWindowsAutomatically = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = wkPreferences
        configuration.allowsInlineMediaPlayback = true
        
        let webview = WKWebView(frame: .zero, configuration: configuration)
        webview.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        /*
        if #available(iOS 16.4, *) {
            webview.isInspectable = true
        } else {
            // Fallback on earlier versions
        };
         */
        webview.isOpaque = false
        webview.backgroundColor = .clear
        webview.scrollView.backgroundColor = .clear

        webview.navigationDelegate = context.coordinator

        if let onPrivoEvent = config.onPrivoEvent {
            let contentController = ContentController(onPrivoEvent)
            webview.configuration.userContentController.add(contentController, name: "privo")
        }
        
        webview.uiDelegate = context.coordinator  //COULD BE POTENTIAL PITFALLS: - BUT ITS CRUCIAL FOR ELIMINATING DOBELLING PERMISSION FOR CAMERA
//        if (config.printCriteria != nil) {
//            webview.uiDelegate = context.coordinator
//        }
        
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
    
    class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private var permissionService: PrivoCameraPermissionServiceType
        private let printLoadingHelper = PrintLoadingHelper();
        
        @Binding
        private var isLoading: Bool
        
        var printCriteria: String?
        var finishCriteria: String?
        var onLoad: (() -> Void)?
        var onFinish: ((String) -> Void)?
        
        // let fileManager = FileManager()
        // var lastFileDestinationURL: URL?
        
        init(_ isLoading: Binding<Bool>, _ permissionService: PrivoCameraPermissionServiceType) {
            self._isLoading = isLoading
            self.permissionService = permissionService
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            var result: WKNavigationActionPolicy = .allow
            defer {
                decisionHandler(result)
            }
            if let url = navigationAction.request.url?.absoluteString,
               let finishCriteria = finishCriteria,
               let onFinish = onFinish {
                if  url.contains(finishCriteria) {
                    onFinish(url)
                    return
                }
            }
            if let url = navigationAction.request.url,
               let scheme = url.scheme {
                if (scheme.lowercased() == "mailto") {
                    result = .cancel
                } else if (scheme.lowercased().starts(with: "http")
                       && navigationAction.navigationType == .linkActivated
                       && url.host?.replacingOccurrences(of: "www.", with: "") == "privo.com")
                {
                    // if user-interaction link inside webview was activated, for example, "Privacy Policy", "Terms of Use" links.
                    result = .cancel
                }
                
                if result == .cancel {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    return
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }

        /*
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading = true
        }
        */

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            
            if let mimeType = navigationResponse.response.mimeType {
                if (mimeType.lowercased().contains("pdf")) {
                    // Will be used in future releases
                    /*
                    if #available(iOS 14.5, *) {
                        decisionHandler(.download)
                    } else {
                        decisionHandler(.cancel)
                    }
                    */
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                if let url = navigationAction.request.url,
                   let printCriteria = printCriteria {
                    if  url.absoluteString.contains(printCriteria) {
                       let newWebView = WKWebView(frame: webView.bounds, configuration: configuration)
                       newWebView.isHidden = true
                       newWebView.navigationDelegate = printLoadingHelper
                       webView.addSubview(newWebView)
                       newWebView.load(navigationAction.request)
                   }
                }
                
            }
            return nil
        }
        
        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView,
                     requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                     initiatedByFrame frame: WKFrameInfo,
                     type: WKMediaCaptureType,
                     decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            permissionService.checkPermission(for: type, completion: decisionHandler)
        }
        
        class PrintLoadingHelper: NSObject, WKNavigationDelegate {
            
            func printWebViewPage(_ webView: WKWebView) {
                let webviewPrint = webView.viewPrintFormatter()
                let printInfo = UIPrintInfo(dictionary: nil)
                printInfo.jobName = "page"
                printInfo.outputType = .general
                let printController = UIPrintInteractionController.shared
                printController.printInfo = printInfo
                printController.showsNumberOfCopies = false
                printController.printFormatter = webviewPrint
                printController.present(animated: true, completionHandler: { [weak webView] _,_,_ in
                    webView?.removeFromSuperview()
                })
            }
            
            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                self.printWebViewPage(webView)
            }
        }
         
         
    }
}
    
    // Will be used in future releases
    /*
    @available(iOS 14.5, *)
    class WebViewNavigationHelperModern: WebViewNavigationHelper, WKDownloadDelegate {

        public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
            download.delegate = self
        }
        public func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
            let temporaryDir = NSTemporaryDirectory()
            let fileName = temporaryDir + suggestedFilename
            let url = URL(fileURLWithPath: fileName)
            lastFileDestinationURL = url
            try? fileManager.removeItem(at: url)
            completionHandler(url)
        }

        public func downloadDidFinish(_ download: WKDownload) {
            if let url = lastFileDestinationURL {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                UIApplication.shared.topMostViewController()?.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
 */


