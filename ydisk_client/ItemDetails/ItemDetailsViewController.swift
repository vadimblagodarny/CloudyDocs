import Foundation
import UIKit
import WebKit

class ItemDetailsViewController: UIViewController {
    var viewModel: ItemDetailsViewModelProtocol!

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.style = .large
        return ai
    }()
    
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
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        viewModel.persistentStoreLoad()
        viewModel.loadItem()
        
        viewModel.loadItemSignal.bind { [weak self] itemUI in
            self?.activityIndicator.stopAnimating()
            if let itemUI = itemUI {
                guard let mime_type = itemUI.mime_type else { return }
                guard let data = itemUI.data else { return }
                let urlString = "data:\(mime_type);base64," + data.base64EncodedString()
                let url = URL(string: urlString)!
                let request = URLRequest(url: url)
                self?.webView.load(request)
            }
        }
    }
}

extension ItemDetailsViewController: WKNavigationDelegate {}
