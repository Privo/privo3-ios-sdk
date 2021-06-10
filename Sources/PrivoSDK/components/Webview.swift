import SwiftUI
import WebKit

struct Webview: UIViewRepresentable {
    
    let url: URL
    let onPrivoEvent: ([String : AnyObject]?) -> Void;
    let navigationHelper = WebViewNavigationHelper()

    func makeUIView(context: UIViewRepresentableContext<Webview>) -> WKWebView {
        let webview = WKWebView()
        webview.navigationDelegate = navigationHelper
        let contentController = ContentController(onPrivoEvent)
        webview.configuration.userContentController.add(contentController, name: "privo")
        
        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
        return webview
    }

    func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<Webview>) {
        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
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
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("webview didFinishNavigation")
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("didStartProvisionalNavigation")
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            print("webviewDidCommit")
        }
        
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            print("didReceiveAuthenticationChallenge")
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

