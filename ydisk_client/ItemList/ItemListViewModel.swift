import Foundation
import UIKit

protocol ItemListViewModelProtocol {
    typealias Routes = OnboardingRoute & ItemDetailsRoute & ItemListRoute
    var itemListRole: ItemListRole { get }
    var onboardingViewDelegate: OnboardingViewDelegate? { get }

    init(router: Routes, network: NetworkProtocol?, role: ItemListRole, path: String)
    
    var itemsSignal: Box<[DataUI]> { get }
    var openItemSignal: Box<DataUI?> { get }
    var invokeAuthSignal: Box<Bool?> { get } // What to do if Token becomes invalid

    func getDiskList()
    func processRawData(items: [RawData]) -> [DataUI]
    
    func openOnboarding()
    func openItem(item: DataUI)
}

class ItemListViewModel: ItemListViewModelProtocol {
    typealias Routes = OnboardingRoute & ItemDetailsRoute & ItemListRoute
    private let router: Routes
    private let network: NetworkProtocol!
    internal let itemListRole: ItemListRole
    internal var diskPath: String
    weak var onboardingViewDelegate: OnboardingViewDelegate?

    var itemsSignal: Box<[DataUI]> = Box([])
    var openItemSignal: Box<DataUI?> = Box(nil)
    var invokeAuthSignal: Box<Bool?> = Box(nil)
    
    required init(router: Routes, network: NetworkProtocol?, role: ItemListRole, path: String) {
        self.network = network
        self.itemListRole = role
        self.diskPath = path
        self.router = router
    }
    
    func openItem(item: DataUI) {
        let urlEncodedString = item.path?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        guard item.type == "dir" else {
            let mimeType = item.mime_type ?? ""
            router.openItemDetails(path: urlEncodedString, mimeType: mimeType, with: PushTransition()) // MARK: move transitioning to router
            return
        }
        let path = urlEncodedString + "&limit=65535"
        router.openItemList(role: ItemListRole.allFilesViewRole, path: path)
    }

    func openOnboarding() {
        router.openOnboarding(opener: self)
    }
    
    func getDiskList() {
        var url: String = ""
        DispatchQueue.global().async {
            
            switch self.itemListRole {
            case .recentsViewRole:
                url = "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded"
            case .allFilesViewRole:
                url = "https://cloud-api.yandex.net/v1/disk/resources?path=\(self.diskPath)"
            }
            
            self.network.dataRequest(url: url) { data, response, error in
                if let error = error { print (error); return }
                if response.statusCode == 401 {
                    DispatchQueue.main.async {
                        self.invokeAuthSignal.value = true
                    }
                    return
                }
                guard let data = data else { return }
                
                switch self.itemListRole {
                case .recentsViewRole:
                    do {
                        let decodedJSON = try JSONDecoder().decode(ResourceList.self, from: data)
                        DispatchQueue.main.async {
                            self.itemsSignal.value = self.processRawData(items: decodedJSON.items ?? [])
                        }
                    } catch {
                        print(error)
                    }
                    
                case .allFilesViewRole:
                    do {
                        let decodedJSON = try JSONDecoder().decode(Resource.self, from: data)
                        DispatchQueue.main.async {
                            self.itemsSignal.value = self.processRawData(items: decodedJSON._embedded?.items ?? [])
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func processRawData(items: [RawData]) -> [DataUI] {
        var dateString: String = ""
        let dateFormatterIn = DateFormatter()
        dateFormatterIn.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let dateFormatterOut = DateFormatter()
        dateFormatterOut.dateFormat = "dd.MM.yy, HH:mm"
        
        var sizeString: String = ""
        let sizeFormatter = ByteCountFormatter()
        sizeFormatter.allowedUnits = [.useAll]
        
        return items.map {
            if $0.size == nil { sizeString = "" } else { sizeString = sizeFormatter.string(fromByteCount: $0.size!) }
            dateString = dateFormatterOut.string(from: (dateFormatterIn.date(from: $0.created!)!))
            
            return DataUI(name: $0.name,
                          preview: $0.preview,
                          created: dateString,
                          path: $0.path,
                          type: $0.type,
                          mime_type: $0.mime_type,
                          size: sizeString)
        }
    }    
}

extension ItemListViewModel: OnboardingViewDelegate {
    func authComplete() {
        getDiskList()
    }
}
