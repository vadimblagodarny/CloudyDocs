import Foundation

protocol AccountViewModelProtocol {
    typealias Routes = AccountRoute & ItemListRoute
    var network: NetworkProtocol! { get }

    init(router: Routes, network: NetworkProtocol?)
    
    func showPublished()
    func createDiagram()
    func endSession()
}

class AccountViewModel: AccountViewModelProtocol {
    typealias Routes = AccountRoute & ItemListRoute
    let network: NetworkProtocol!
    internal let router: Routes
    
    required init(router: Routes, network: NetworkProtocol?) {
        self.router = router
        self.network = network
    }
    
    func showPublished() {
        
    }
    
    func createDiagram() {
        
    }
    
    func endSession() {
        
    }
}
