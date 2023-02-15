import Foundation
import UIKit
import WebKit

class OnboardingViewController: UIViewController {

    var viewModel: OnboardingViewModelProtocol!
    weak var loginViewDelegate: LoginViewDelegate?
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Resources.Images.onboardingBackground
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var onboardingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Welcome"
        return label
    }()
    
    private lazy var proceedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Resources.Colors.primaryAccentColor
        button.addTarget(self, action: #selector(proceedTap), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        if UserDefaults.standard.string(forKey: "OnboardingVisited") != nil {
            proceedToAuth()
        } else {
            setupViews()
            UserDefaults.standard.set("", forKey: "OnboardingVisited") // Flag setting on first run
        }
    }
    
    func setupViews() {
        view.addSubview(backgroundImageView)
//        view.addSubview(onboardingLabel)
        view.addSubview(proceedButton)
        backgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        onboardingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        onboardingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -20).isActive = true
        proceedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        proceedButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
    }

    func proceedToAuth() {
        // Try to use locally stored authentication token
        if let token = UserDefaults.standard.string(forKey: "API.Token") {
            Token.value = token
            viewModel.onboardingViewDelegate?.authComplete() // >> ItemListViewModel.getDiskList()
            viewModel.close()
        } else if Token.value.isEmpty {
            viewModel.openLogin()
        } else {
            return
        }
    }
    
    @objc func proceedTap(sender: UIButton!) {
        proceedToAuth()
    }
    
}
