import UIKit

protocol ItemListRoute {
    func makeItemList(role: ItemListRole, tabImage: UIImage, path: String?) -> UIViewController
    func openItemList(role: ItemListRole, path: String?)
}

extension ItemListRoute where Self: Router { // Recents & All Files View Route
    func makeItemList(role: ItemListRole, tabImage: UIImage, path: String?) -> UIViewController {
        let router = DefaultRouter(rootTransition: EmptyTransition())
        let network = Network()
        let viewModel = ItemListViewModel(router: router, network: network, role: role, path: path ?? "")
        let view = ItemListViewController()
        view.viewModel = viewModel
        router.root = view
        let navigation = UINavigationController(rootViewController: view)
        navigation.tabBarItem = UITabBarItem(title: role.rawValue, image: tabImage, tag: 0)
        return navigation
    }

    func openItemList(role: ItemListRole, path: String?) {
        let router = DefaultRouter(rootTransition: PushTransition())
        let network = Network()
        let viewModel = ItemListViewModel(router: router, network: network, role: role, path: path ?? "")
        let view = ItemListViewController()
        view.viewModel = viewModel
        router.root = view
        route(to: view, as: PushTransition())
    }
}

extension DefaultRouter: ItemListRoute {}
