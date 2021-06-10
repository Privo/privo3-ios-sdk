import SwiftUI
import WebKit

struct Webview: UIViewRepresentable {
    
    let url: URL
    let onPrivoEvent: ([String : AnyObject]?) -> Void;

    func makeUIView(context: UIViewRepresentableContext<Webview>) -> WKWebView {
        let webview = WKWebView()
        webview.translatesAutoresizingMaskIntoConstraints = false
        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
        return webview
    }

    func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<Webview>) {
        let contentController = ContentController(onPrivoEvent)
        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        webview.configuration.userContentController.add(contentController, name: "privo")
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
}

