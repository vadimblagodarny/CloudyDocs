import Foundation
import UIKit
import WebKit

class OnboardingViewController: UIViewController {

    var viewModel: OnboardingViewModelProtocol!
    weak var loginViewDelegate: LoginViewDelegate?

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isPagingEnabled = true
        sv.contentSize.width = view.frame.width * 3
        sv.addSubview(onboardingLabelOne)
        sv.addSubview(onboardingLabelTwo)
        sv.addSubview(onboardingLabelThree)
        return sv
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Resources.Images.onboardingBackground
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        return imageView
    }()
    
    private lazy var onboardingLabelOne: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Теперь все ваши\nдокументы в одном месте"
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var onboardingLabelTwo: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Доступ к файлам\nбез интернета"
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var onboardingLabelThree: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Делитесь вашими\nфайлами с другими"
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var proceedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.setTitle("Далее", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = Resources.Colors.primaryAccentColor
        button.addTarget(self, action: #selector(proceedTap), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        button.tag = 1
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        if UserDefaults.standard.bool(forKey: "SeenOnboarding") == true {
            proceedToAuth()
        } else {
            setupViews()
            UserDefaults.standard.set(true, forKey: "SeenOnboarding") // Flag setting on first run
        }
    }
    
    func setupViews() {
        navigationController?.isNavigationBarHidden = true
        
//        view.addSubview(backgroundImageView)
        view.addSubview(scrollView)
        view.addSubview(proceedButton)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        proceedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        proceedButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true

        // centerX constant scale factor: x0 - first screen, x1.5 - second screen, x1 - third screen
        onboardingLabelOne.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        onboardingLabelOne.widthAnchor.constraint(equalToConstant: 300).isActive = true
        onboardingLabelOne.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        
        onboardingLabelTwo.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: scrollView.contentSize.width / 1.5).isActive = true
        onboardingLabelTwo.widthAnchor.constraint(equalToConstant: 300).isActive = true
        onboardingLabelTwo.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        
        onboardingLabelThree.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: scrollView.contentSize.width).isActive = true
        onboardingLabelThree.widthAnchor.constraint(equalToConstant: 300).isActive = true
        onboardingLabelThree.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        
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
    
    @objc func nextOnboarding(sender: UIButton!) {
    }
    
    @objc func proceedTap(sender: UIButton!) {
        sender.tag += 1

        if sender.tag == 4 {
            navigationController?.isNavigationBarHidden = false
            proceedToAuth()
            return
        } else if sender.tag == 3 {
            sender.setTitle("Войти", for: .normal)
        }
        
        scrollView.setContentOffset(CGPoint(x: view.frame.size.width * CGFloat(sender.tag), y: 0), animated:true)

    }
    
}
