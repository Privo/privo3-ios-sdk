import SwiftUI
import WebKit

struct Webview: UIViewRepresentable {
    
    let url: URL

    func makeUIView(context: UIViewRepresentableContext<Webview>) -> WKWebView {
        let webview = WKWebView()
        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
        return webview
    }

    func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<Webview>) {
        let contentController = ContentController()
        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        webview.configuration.userContentController.add(contentController, name: "test")
        webview.load(request)
    }
    
    class ContentController: WKUserContentController, WKScriptMessageHandler {
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print(message)
            guard let dict = message.body as? [String : AnyObject] else {
                return
            }
            print(dict)
        }
    }
}

