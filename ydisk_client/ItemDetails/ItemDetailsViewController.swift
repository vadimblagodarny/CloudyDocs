import Foundation
import UIKit
import WebKit
import PDFKit

class ItemDetailsViewController: UIViewController {
    var viewModel: ItemDetailsViewModelProtocol!

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.style = .large
        return ai
    }()
    
    private lazy var progressView: UIProgressView = {
        let pv = UIProgressView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.layer.cornerRadius = 10
        pv.clipsToBounds = true
        return pv
    }()
    
    private lazy var pdfView: PDFView = {
        let pv = PDFView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.autoScales = true
        return pv
    }()
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.overrideUserInterfaceStyle = .dark
        tabBarController?.overrideUserInterfaceStyle = .dark

        view.addSubview(activityIndicator)
        view.addSubview(progressView)
        activityIndicator.startAnimating()

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            progressView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -40),
            progressView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        viewModel.persistentStoreLoad()
        viewModel.loadItem()
        
        viewModel.loadItemSignal.bind { [weak self] itemUI in
            self?.activityIndicator.stopAnimating()
            if let itemUI = itemUI {
                guard let mime_type = itemUI.mime_type else { return }
                guard let data = itemUI.data else { return }
                
                if mime_type.hasPrefix("application/pdf") {
                    self?.openPDF(data: data)
                } else {
                    let urlString = "data:\(mime_type);base64," + data.base64EncodedString()
                    let url = URL(string: urlString)!
                    let request = URLRequest(url: url)
                    self?.openOther(request: request)
                }
            }
        }
        
        viewModel.network.networkProgressSignal.bind { [weak self] progress in
            self?.progressView.progress = Float(progress)
            if progress == 1 { self?.progressView.removeFromSuperview() }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .black
        view.overrideUserInterfaceStyle = .dark
        tabBarController?.overrideUserInterfaceStyle = .dark
    }
    
    func openPDF(data: Data) {
        view.addSubview(pdfView)
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        pdfView.document = PDFDocument(data: data)
    }
    
    func openOther(request: URLRequest) {
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        webView.load(request)
    }
    
}

extension ItemDetailsViewController: WKNavigationDelegate {
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        webView.isOpaque = false
//    }
}
