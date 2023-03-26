import Foundation
import WebKit

protocol LoginViewDelegate: AnyObject {
    func passToken(token: String)
}

protocol LoginViewModelProtocol: WKNavigationDelegate {
    typealias Routes = LoginRoute & Dismissable
    var apiURL: String { get }
    var clientID: String { get }
    var loginViewDelegate: LoginViewDelegate? { get }

    func dismiss()
    func makeAuthRequest(apiURL: String, clientID: String) -> URLRequest?
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
}

class LoginViewModel: NSObject, LoginViewModelProtocol {
    typealias Routes = LoginRoute & Dismissable
    private var router: Routes
    let apiURL: String = "https://oauth.yandex.ru/authorize"
    let clientID: String = "dec10f9ae9074b87a8551a9e21114bad"
    weak var loginViewDelegate: LoginViewDelegate?

    init(router: Routes) {
        self.router = router
    }

    func dismiss() {
        router.dismiss()
    }
    
    func makeAuthRequest(apiURL: String, clientID: String) -> URLRequest? {
        var request: URLRequest? {
            guard var urlComponents = URLComponents(string: apiURL) else { return nil }
            urlComponents.queryItems = [
                URLQueryItem(name: "response_type", value: "token"),
                URLQueryItem(name: "client_id", value: clientID)
            ]
            guard let url = urlComponents.url else { return nil }
            return URLRequest(url: url)
        }
        return request
    }
}

extension LoginViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let targetString = url.absoluteString.replacingOccurrences(of: "#", with: "?")
            guard let components = URLComponents(string: targetString) else { return }
            if let token = components.queryItems?.first(where: { $0.name == "access_token" })?.value {
                UserDefaults.standard.set(token, forKey: "API.Token")
                loginViewDelegate?.passToken(token: token)
                self.dismiss()
            }
        }
        decisionHandler(.allow)
    }
}
