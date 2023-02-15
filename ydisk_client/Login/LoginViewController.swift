import UIKit
import WebKit

protocol LoginViewDelegate: AnyObject { // MARK: Move delegate and extension to viewmodel
    func passToken(token: String)
}

class LoginViewController: UIViewController {
    var viewModel: LoginViewModelProtocol!
    let loginView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginView.navigationDelegate = viewModel.self
        setupViews()

        if let request = viewModel.makeAuthRequest(apiURL: viewModel.apiURL, clientID: viewModel.clientID) {
            loginView.load(request)
        } else { }

    }

    private func setupViews() {
        view.addSubview(loginView)
        loginView.translatesAutoresizingMaskIntoConstraints = false
        loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        loginView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

