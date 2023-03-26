import Foundation
import UIKit
import WebKit

class OnboardingViewController: UIViewController {

    var viewModel: OnboardingViewModelProtocol!
    weak var loginViewDelegate: LoginViewDelegate?

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.pageIndicatorTintColor = Resources.Colors.primaryAccentColor
        pc.currentPageIndicatorTintColor = .black
        pc.numberOfPages = 3
        pc.currentPage = 0
        pc.isEnabled = false
        return pc
    }()
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isPagingEnabled = true
        sv.isScrollEnabled = false
        sv.contentSize.width = view.frame.width * 3
        sv.addSubview(backgroundLineImageView)
        sv.addSubview(onboardingLabelOne)
        sv.addSubview(onboardingIconOne)
        sv.addSubview(onboardingLabelTwo)
        sv.addSubview(onboardingIconTwo)
        sv.addSubview(onboardingLabelThree)
        sv.addSubview(onboardingIconThree)
        return sv
    }()
    
    private lazy var backgroundLineImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = Resources.Images.onboardingFlow
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var onboardingLabelOne: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Text.Onboarding.labelOne
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var onboardingLabelTwo: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Text.Onboarding.labelTwo
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var onboardingLabelThree: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Text.Onboarding.labelThree
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var onboardingIconOne: UIImageView = {
        let image = UIImage(systemName: "doc") ?? UIImage()
        let iv = UIImageView(image: image)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .black
        return iv
    }()
    
    private lazy var onboardingIconTwo: UIImageView = {
        let image = UIImage(systemName: "wifi.slash") ?? UIImage()
        let iv = UIImageView(image: image)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .black
        return iv
    }()
    
    private lazy var onboardingIconThree: UIImageView = {
        let image = UIImage(systemName: "square.and.arrow.up") ?? UIImage()
        let iv = UIImageView(image: image)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .black
        return iv
    }()

    private lazy var proceedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.setTitle(Text.Onboarding.buttonNext, for: .normal)
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
        tabBarController?.tabBar.isHidden = true
        
        view.addSubview(scrollView)
        view.addSubview(proceedButton)
        view.addSubview(pageControl)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        proceedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        proceedButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: proceedButton.topAnchor, constant: -20).isActive = true
        pageControl.widthAnchor.constraint(equalToConstant: 200).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // centerX constant scale factor: x0 - first screen, x1.5 - second screen, x1 - third screen
        onboardingLabelOne.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        onboardingLabelOne.widthAnchor.constraint(equalToConstant: 300).isActive = true
        onboardingLabelOne.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        onboardingIconOne.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        onboardingIconOne.widthAnchor.constraint(equalToConstant: 100).isActive = true
        onboardingIconOne.heightAnchor.constraint(equalToConstant: 100).isActive = true
        onboardingIconOne.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        onboardingLabelTwo.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: scrollView.contentSize.width / 1.5).isActive = true
        onboardingLabelTwo.widthAnchor.constraint(equalToConstant: 300).isActive = true
        onboardingLabelTwo.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        onboardingIconTwo.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: scrollView.contentSize.width / 1.5).isActive = true
        onboardingIconTwo.widthAnchor.constraint(equalToConstant: 100).isActive = true
        onboardingIconTwo.heightAnchor.constraint(equalToConstant: 100).isActive = true
        onboardingIconTwo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        onboardingLabelThree.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: scrollView.contentSize.width).isActive = true
        onboardingLabelThree.widthAnchor.constraint(equalToConstant: 300).isActive = true
        onboardingLabelThree.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        onboardingIconThree.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: scrollView.contentSize.width).isActive = true
        onboardingIconThree.widthAnchor.constraint(equalToConstant: 100).isActive = true
        onboardingIconThree.heightAnchor.constraint(equalToConstant: 100).isActive = true
        onboardingIconThree.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        backgroundLineImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 4).isActive = true
        backgroundLineImageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
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
        sender.tag += 1
        pageControl.currentPage += 1

        if sender.tag == 4 {
            navigationController?.isNavigationBarHidden = false
            proceedToAuth()
            return
        } else if sender.tag == 3 {
            sender.setTitle(Text.Onboarding.buttonLogin, for: .normal)
        }
        
        scrollView.setContentOffset(CGPoint(x: view.frame.size.width * CGFloat(sender.tag), y: 0), animated:true)
    }
    
}
