import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    let url: URL
    let success: (String) -> Void
    let webView = WKWebView()
    
    func makeUIView(context: Context) -> WKWebView {
        let request = URLRequest(url: url)
        self.webView.load(request)
        self.webView.navigationDelegate = context.coordinator
        return self.webView
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        
        let success: (String) -> Void
        
        init(success: @escaping (String) -> Void) {
            self.success = success
        }
        
        func webView(_ webView: WKWebView,
                     didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            let dataStore = WKWebsiteDataStore.default()
            dataStore.httpCookieStore.getAllCookies({ (cookies) in
                let cookie = cookies.first() {cookie in
                    return cookie.name == "_veracross_session"
                }
                if (cookie != nil) {
                    self.success(cookie!.value)
                }
            })
        }
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        return
    }
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(success: success)
    }
}
