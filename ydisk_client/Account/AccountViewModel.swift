import Foundation

protocol AccountViewModelProtocol {
    typealias Routes = AccountRoute & ItemListRoute
    var network: NetworkProtocol! { get }
    var diskInfoSignal: Box<DiskInfo?> { get }

    init(router: Routes, network: NetworkProtocol?)
    
    func getDiskInfo()
    func showPublished()
    func createDiagram()
    func endSession()
}

class AccountViewModel: AccountViewModelProtocol {
    typealias Routes = AccountRoute & ItemListRoute
    let network: NetworkProtocol!
    internal let router: Routes
    var diskInfoSignal: Box<DiskInfo?> = Box(nil)
    
    required init(router: Routes, network: NetworkProtocol?) {
        self.router = router
        self.network = network
    }
    
    func getDiskInfo() {
        let url: String = "https://cloud-api.yandex.net/v1/disk/"

        DispatchQueue.global().async {
            self.network.dataRequest(method: "GET", url: url) { data, response, error in
                if let error = error { return }

                guard let data = data else { return }
                Flag.offlineWarned = false // Сеть появилась -> сброс предупреждения об отсуствии сети

                do {
                    let decodedJSON = try JSONDecoder().decode(DiskInfo.self, from: data)
                    DispatchQueue.main.async {
                        self.diskInfoSignal.value = decodedJSON
                    }
                } catch {
                    print("JSON decoding error: \(error)")
                }
            }
        }
    }

    func showPublished() {
        router.openItemList(role: .publishedViewRole, path: nil)
    }
    
    func createDiagram() {

    }
    
    func endSession() {
        
    }
}
