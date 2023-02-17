import Foundation
import UIKit
import WebKit

class ItemDetailsViewController: UIViewController {
    var viewModel: ItemDetailsViewModelProtocol!

    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.backgroundColor = .white
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(webView)
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        webView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        webView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let urlString = "https://cloud-api.yandex.net/v1/disk/resources/download?path=" + viewModel.diskPath

        DispatchQueue.global().async {
            self.viewModel.network.dataRequest(url: urlString) { data, response, error in
                let url = URL(string: urlString)!
                var urlRequest = URLRequest(url: url)
                urlRequest.httpMethod = "GET"
                urlRequest.setValue("OAuth \(Token.value)", forHTTPHeaderField: "Authorization")
                URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                    if let error = error { return }
                    guard let data = data else { return }
                    let downloadLink = try? JSONDecoder().decode(Download.self, from: data)
                    DispatchQueue.main.async {
                        self.webView.load(URLRequest(url: URL(string: (downloadLink?.href)!)!))
                    }
                }.resume()
            }
        }
    }
}

extension ItemDetailsViewController: WKNavigationDelegate {}
