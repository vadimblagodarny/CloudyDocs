import Foundation

protocol OnboardingViewDelegate: AnyObject {
    func authComplete()
}

protocol OnboardingViewModelProtocol {
    typealias Routes = LoginRoute & Closable
    func openLogin()
    func close()
    var onboardingViewDelegate: OnboardingViewDelegate? { get }
}

class OnboardingViewModel: OnboardingViewModelProtocol {
    typealias Routes = LoginRoute & Closable
    private var router: Routes
    weak var onboardingViewDelegate: OnboardingViewDelegate?
    
    init(router: Routes) {
        self.router = router
    }

    func openLogin() {
        router.openLogin(opener: self)
    }
    
    func close() {
        router.close()
    }
}

extension OnboardingViewModel: LoginViewDelegate {
    func passToken(token: String) {
        onboardingViewDelegate?.authComplete()
        self.close()
    }
}
