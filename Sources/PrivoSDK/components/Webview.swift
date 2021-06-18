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
        let userContentController = WKUserContentController()
        testScripts(userContentController)
        webview.configuration.userContentController = userContentController
        //if let onPrivoEvent = config.onPrivoEvent {
            // let contentController = ContentController(onPrivoEvent)
            // webview.configuration.userContentController.add(contentController, name: "privo")
        //}
        let request = URLRequest(url: config.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
        return webview
    }

    func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<Webview>) {
        let request = URLRequest(url: config.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
    }
    
    func testScripts(_ contentController: WKUserContentController) {
        let script =    """
                        alert("Ops! We can inject JS!!!");
                        console.log("Ops! We can inject JS!!!")
                        var script = document.createElement('script');
                        script.src = 'https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.2/MathJax.js?config=default&#038;ver=1.3.8';
                        script.type = 'text/javascript';
                        document.getElementsByTagName('head')[0].appendChild(script);
                        """
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
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
            if let url = navigationAction.request.url?.absoluteString,
               let finishCriteria = finishCriteria,
               let onFinish = onFinish {
                if  url.contains(finishCriteria) {
                    onFinish(url)
                }
            }
            decisionHandler(.allow)
        }
    }
}

