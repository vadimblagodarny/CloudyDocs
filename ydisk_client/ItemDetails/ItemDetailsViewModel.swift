import Foundation
import UIKit

protocol ItemDetailsViewModelProtocol {
    typealias Routes = ItemDetailsRoute & LoginRoute & Closable
    var diskPath: String { get }
    var network: NetworkProtocol! { get }

    init(router: Routes, network: NetworkProtocol?, path: String, mimeType: String)
    
    func openItemDetails(path: String, mimeType: String)
    func close()
}

class ItemDetailsViewModel: ItemDetailsViewModelProtocol {
    typealias Routes = ItemDetailsRoute & LoginRoute & Closable

    internal let router: Routes
    let network: NetworkProtocol!
    var diskPath: String
    var mimeType: String
    
    required init(router: Routes, network: NetworkProtocol?, path: String, mimeType: String) {
        self.router = router
        self.network = network
        self.diskPath = path
        self.mimeType = mimeType
    }
    
    func openItemDetails(path: String, mimeType: String) {
        router.openItemDetails(path: path, mimeType: mimeType, with: PushTransition())
    }

    func close() {
        router.close()
    }

}
