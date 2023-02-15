import UIKit

protocol OnboardingRoute {
    func openOnboarding(opener: OnboardingViewDelegate)
}

extension OnboardingRoute where Self: Router {
    func openOnboarding(opener: OnboardingViewDelegate, with transition: Transition) {
        let router = DefaultRouter(rootTransition: transition)
        let viewModel = OnboardingViewModel(router: router)
        let view = OnboardingViewController()
        viewModel.onboardingViewDelegate = opener // itemListViewModel
        view.viewModel = viewModel
        view.navigationItem.hidesBackButton = true
        router.root = view
        route(to: view, as: transition)
    }

    func openOnboarding(opener: OnboardingViewDelegate) {
        openOnboarding(opener: opener, with: PushTransition(isAnimated: true))
    }
}

extension DefaultRouter: OnboardingRoute {}
