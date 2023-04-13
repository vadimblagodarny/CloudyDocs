import Foundation
import CoreData

protocol AccountViewModelProtocol {
    typealias Routes = AccountRoute & ItemListRoute & LoginRoute
    var network: NetworkProtocol! { get }
    var diskInfoSignal: Box<DiskInfo?> { get }
    var persistentContainer: NSPersistentContainer { get }
    var onboardingViewDelegate: OnboardingViewDelegate? { get }

    init(router: Routes, network: NetworkProtocol?)
    
    func loadPersistentStores()
    func getDiskInfo()
    func showPublished()
    func dataReset()
    func endSession()
}

class AccountViewModel: AccountViewModelProtocol {
    typealias Routes = AccountRoute & ItemListRoute & LoginRoute
    let network: NetworkProtocol!
    internal let router: Routes
    var diskInfoSignal: Box<DiskInfo?> = Box(nil)
    internal let persistentContainer = NSPersistentContainer(name: "ydisk_client")
    weak var onboardingViewDelegate: OnboardingViewDelegate?

    required init(router: Routes, network: NetworkProtocol?) {
        self.router = router
        self.network = network
    }
    
    func loadPersistentStores() {
        persistentContainer.loadPersistentStores { persistentStoreDescription, error in }
    }
    
    func getDiskInfo() {
        let url: String = "https://cloud-api.yandex.net/v1/disk/"

        DispatchQueue.global().async {
            self.network.dataRequest(method: "GET", url: url) { data, response, error in
                if let error = error { return }

                guard let data = data else { return }
                Flag.offlineWarned = false

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
    
    func dataReset() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }

        let context = self.persistentContainer.viewContext
        let entities = ["DataOfflinePublished", "DataOfflineResource", "DataOfflineRecent", "DataOfflineItem"]

        for entity in entities {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try self.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
            } catch let error {
                print("Core Data cleanup error: \(error)")
            }
        }
    }
    
    func endSession() {
        dataReset()
        router.openLogin(opener: nil)
    }
}
