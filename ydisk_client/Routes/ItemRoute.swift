import Foundation

protocol ItemDetailsRoute {
    func openItemDetails(path: String, mimeType: String, with transition: Transition)
}

extension ItemDetailsRoute where Self: Router {
    func openItemDetails(path: String, mimeType: String, with transition: Transition) {
        let router = DefaultRouter(rootTransition: transition)
        let network = Network()
        let viewModel = ItemDetailsViewModel(router: router, network: network, path: path, mimeType: mimeType)
        let view = ItemDetailsViewController()
        view.viewModel = viewModel
        router.root = view
        route(to: view, as: transition)
    }
}

extension DefaultRouter: ItemDetailsRoute {}
