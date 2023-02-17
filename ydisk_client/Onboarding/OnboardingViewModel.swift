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
    typealias Routes = LoginRoute & Closable // Направления, в которых возможно движение из этого класса
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
        Token.value = token
        onboardingViewDelegate?.authComplete()
        self.close()
    }
}
