import UIKit

protocol AccountRoute {
    func makeAccount() -> UIViewController
}

extension AccountRoute where Self: Router {
    func makeAccount() -> UIViewController {
        let router = DefaultRouter(rootTransition: EmptyTransition())
        let network = Network()
        let viewModel = AccountViewModel(router: router, network: network)
        let view = AccountViewController()
        view.viewModel = viewModel
        router.root = view
        let navigation = UINavigationController(rootViewController: view)
        navigation.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.crop.circle"), tag: 1)
        return navigation
    }
}

extension DefaultRouter: AccountRoute {}
