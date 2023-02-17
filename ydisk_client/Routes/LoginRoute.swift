import UIKit

protocol LoginRoute {
    func openLogin(opener: LoginViewDelegate)
}

extension LoginRoute where Self: Router {
    func openLogin(opener: LoginViewDelegate, with transition: Transition) {
        let router = DefaultRouter(rootTransition: transition)
        let viewModel = LoginViewModel(router: router)
        let view = LoginViewController()
        viewModel.loginViewDelegate = opener // onboardingViewModel
        view.viewModel = viewModel
        view.isModalInPresentation = true
        router.root = view
        route(to: view, as: transition)
    }

    func openLogin(opener: LoginViewDelegate) {
        openLogin(opener: opener, with: ModalTransition())
    }
}

extension DefaultRouter: LoginRoute {}
