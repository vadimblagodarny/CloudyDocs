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
    
    private lazy var fileInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
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
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.addTarget(self, action: #selector(shareButtonTap), for: .touchUpInside)
        button.tintColor = .lightGray
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "delete.left"), for: .normal)
        button.addTarget(self, action: #selector(deleteButtonTap), for: .touchUpInside)
        button.tintColor = .lightGray
        return button
    }()
    
    private lazy var renameButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "character.cursor.ibeam")
        button.style = .plain
        button.target = self
        button.action = #selector(renameButtonTap)
        return button
    }()
    
    var dataToShare: Data = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        viewModel.persistentStoreLoad()
        activityIndicator.startAnimating()
        viewModel.loadItem()
        
        viewModel.itemLoadedSignal.bind { [weak self] itemUI in
            self?.activityIndicator.stopAnimating()
            if let itemUI = itemUI {
                guard let mime_type = itemUI.mime_type else { return }
                guard let data = itemUI.data else { return }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
                self?.fileInfoLabel.text = dateFormatter.string(from: itemUI.created ?? Date())
                
                if mime_type.hasPrefix("application/pdf") {
                    self?.openPDF(data: data)
                } else {
                    self?.dataToShare = data
                    let urlString = "data:\(mime_type);base64," + data.base64EncodedString()
                    let url = URL(string: urlString)!
                    let request = URLRequest(url: url)
                    self?.openOther(request: request)
                }
            }
        }
        
        viewModel.network.networkProgressSignal.bind { [weak self] progress in
            self?.progressView.progress = Float(progress ?? 0.0)
            if progress == 1 { self?.progressView.removeFromSuperview() }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .black
        view.overrideUserInterfaceStyle = .dark
        tabBarController?.overrideUserInterfaceStyle = .dark
        tabBarController?.tabBar.isHidden = true
        navigationItem.title = viewModel.dataUI.name
        navigationItem.rightBarButtonItems = [renameButton]
    }
    
    func setupViews() {
        view.addSubview(fileInfoLabel)
        view.addSubview(shareButton)
        view.addSubview(deleteButton)
        view.addSubview(pdfView)
        view.addSubview(webView)
        view.addSubview(progressView)
        view.addSubview(activityIndicator)

        webView.isHidden = true
        pdfView.isHidden = true
        
        NSLayoutConstraint.activate([
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            shareButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            deleteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            fileInfoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            fileInfoLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            fileInfoLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            progressView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -200),
            progressView.heightAnchor.constraint(equalToConstant: 20),
            pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: fileInfoLabel.bottomAnchor, constant: 16),
            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: fileInfoLabel.bottomAnchor, constant: 16),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

    }
    
    func openPDF(data: Data) {
        pdfView.isHidden = false
        pdfView.document = PDFDocument(data: data)
    }
    
    func openOther(request: URLRequest) {
        webView.isHidden = false
        webView.load(request)
    }
    
    @objc func shareButtonTap(_ sender: UIButton) {
        let alert = UIAlertController(title: Text.ItemDetails.alertShareTitle,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        alert.addAction(
            .init(title: Text.ItemDetails.alertShareButtonFile, style: .default) { [weak self] _ in
                let activityVC = UIActivityViewController(activityItems: [self?.dataToShare as Any], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = sender
                self?.present(activityVC, animated: true, completion: nil)
            }
        )
        
        alert.addAction(
            .init(title: Text.ItemDetails.alertShareButtonLink, style: .default) { [weak self]_ in
                self?.activityIndicator.startAnimating()
                let itemToShare = self?.viewModel.shareItem()
                let activityVC = UIActivityViewController(activityItems: [itemToShare as Any], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = sender
                self?.present(activityVC, animated: true, completion: nil)
                self?.activityIndicator.stopAnimating()
            }
        )
        
        alert.addAction(
            .init(title: Text.Common.buttonCancel, style: .cancel)
        )
        
        self.present(alert, animated: true)
    }
    
    @objc func deleteButtonTap() {
        let alert = UIAlertController(title: Text.ItemDetails.alertDeleteTitle,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        alert.addAction(
            .init(title: Text.ItemDetails.alertDeleteButton, style: .destructive) { [weak self] _ in
                if ((self?.viewModel.deleteItem()) != nil) {
                    Flag.needsReload = true
                    self?.viewModel.close()
                }
            }
        )
        
        alert.addAction(
            .init(title: Text.Common.buttonCancel, style: .cancel)
        )
        
        self.present(alert, animated: true)
    }

    @objc func renameButtonTap() {
        let itemCurrentPath = viewModel.dataUI.path!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let itemFullName = viewModel.dataUI.name!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let itemPath = itemCurrentPath.prefix(itemCurrentPath.count - itemFullName.count)
        let itemName = NSString(string: itemFullName).deletingPathExtension
        let itemExtension = "." + NSString(string: itemFullName).pathExtension

        let alert = UIAlertController(title: Text.ItemDetails.alertRenameTitle, message: nil, preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = itemName
        }

        alert.addAction(UIAlertAction(title: Text.Common.buttonOk, style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            let itemNewPath = itemPath + textField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + itemExtension.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let renamed = self.viewModel.renameItem(currentPath: itemCurrentPath, newPath: String(itemNewPath))
            if renamed {
                Flag.needsReload = true
                self.navigationItem.title = textField.text! + itemExtension
            }
        }))
        
        alert.addAction(UIAlertAction(title: Text.Common.buttonCancel, style: .cancel))

        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ItemDetailsViewController: WKNavigationDelegate {}
