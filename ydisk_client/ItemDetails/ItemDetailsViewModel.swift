import Foundation
import UIKit
import CoreData

protocol ItemDetailsViewModelProtocol {
    typealias Routes = ItemDetailsRoute & LoginRoute & Closable
    var network: NetworkProtocol! { get }
    var dataUI: DataUI { get }

    var persistentContainer: NSPersistentContainer { get }
    var itemFetchedResultsController: NSFetchedResultsController<DataOfflineItem> { get }

    var itemLoadedSignal: Box<ItemUI?> { get }

    init(router: Routes, network: NetworkProtocol?, dataUI: DataUI)
    
    func persistentStoreLoad()
    func loadItem()
    func shareItem() -> URL?
    func deleteItem() -> Bool
    func renameItem(currentPath: String, newPath: String) -> Bool
    func close()
}

class ItemDetailsViewModel: ItemDetailsViewModelProtocol {
    typealias Routes = ItemDetailsRoute & LoginRoute & Closable

    internal let router: Routes
    let network: NetworkProtocol!
    var dataUI: DataUI

    internal let persistentContainer = NSPersistentContainer(name: "ydisk_client")
    
    internal lazy var itemFetchedResultsController: NSFetchedResultsController<DataOfflineItem> = {
        let fetchRequest = DataOfflineItem.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "md5", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    var itemLoadedSignal: Box<ItemUI?> = Box(nil)

    required init(router: Routes, network: NetworkProtocol?, dataUI: DataUI) {
        self.router = router
        self.network = network
        self.dataUI = dataUI
    }
    
    func persistentStoreLoad() {
        persistentContainer.loadPersistentStores { persistentStoreDescription, error in
            if let error = error {
                print("Error loading persistent stores: \(error)")
            } else {
                do {
                    try self.itemFetchedResultsController.performFetch()
                } catch {
                    print(error)
                }
            }
        }
    }

    func loadItem() {
        let urlString = "https://cloud-api.yandex.net/v1/disk/resources/download?path=" + self.dataUI.path!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

        DispatchQueue.global().async {
            self.network.dataRequest(method: "GET", url: urlString) { data, response, error in
                if error != nil {
                    // MARK: - Обработка ошибки соединения и подгрузка данных из Core Data
                    let fetchRequest = self.itemFetchedResultsController.fetchRequest
                    let context = self.persistentContainer.viewContext

                    do {
                        let objects = try context.fetch(fetchRequest)
                        let object = objects.filter{ $0.md5 == self.dataUI.md5 }.first
                        DispatchQueue.main.async {
                            self.itemLoadedSignal.value = ItemUI(name: self.dataUI.name,
                                                               data: object?.data,
                                                               created: self.dataUI.created,
                                                               mime_type: self.dataUI.mime_type,
                                                               size: self.dataUI.size)
                        }
                    } catch {
                        print("Core Data fetch error: \(error)")
                    }
                    return
                }
                
                guard let data = data else { return }
                let downloadLink = try? JSONDecoder().decode(Download.self, from: data)
                let downloadURL = URL(string: downloadLink?.href ?? "")!

                DispatchQueue.main.async {
                    var downloadedObject: Data = Data()
                    
                    DispatchQueue.global().async {
                        do {
                            try downloadedObject = Data(contentsOf: downloadURL)
                            
                            DispatchQueue.main.async {
                                self.itemLoadedSignal.value = ItemUI(name: self.dataUI.name,
                                                                   data: downloadedObject,
                                                                   created: self.dataUI.created,
                                                                   mime_type: self.dataUI.mime_type,
                                                                   size: self.dataUI.size)
                            }
                            
                            // MARK: - Инициализация Core Data и получение всех объектов
                            let context = self.persistentContainer.viewContext
                            let entity = NSEntityDescription.entity(forEntityName: "DataOfflineItem", in: context)
                            let fetchRequest = self.itemFetchedResultsController.fetchRequest
                            var objects: [DataOfflineItem] = []

                            do {
                                objects = try context.fetch(fetchRequest)
                            } catch {
                                print("Core Data fetch error: \(error)")
                            }
                            
                            // MARK: - Проверка на существующий объект в Core Data и сохранение нового
                            if !objects.contains(where: { $0.md5 == self.dataUI.md5 }) {
                                let object = NSManagedObject(entity: entity!, insertInto: context)
                                                                
                                object.setValue(self.dataUI.md5, forKey: "md5")
                                object.setValue(downloadedObject, forKey: "data")

                                do {
                                    try context.save()
                                } catch {
                                    print("Core Data save error: \(error)")
                                }
                            }

                            
                        } catch {
                            print("Item downloading error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    func shareItem() -> URL? {
        let semaphore = DispatchSemaphore(value: 0)
        let urlString = "https://cloud-api.yandex.net/v1/disk/resources/publish?path=" + self.dataUI.path!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        var publishURL: URL?
        
        DispatchQueue.global().async {
            self.network.dataRequest(method: "PUT", url: urlString) { data, response, error in
                if error != nil { return }
                guard let data = data else { return }
                let publishLink = try? JSONDecoder().decode(Link.self, from: data)
                publishURL = URL(string: publishLink?.href ?? "")!
                semaphore.signal()
            }
        }
        semaphore.wait()
        return publishURL
    }

    func deleteItem() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        let urlString = "https://cloud-api.yandex.net/v1/disk/resources?path=" + self.dataUI.path!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        var deleted: Bool = false
        
        DispatchQueue.global().async {
            self.network.dataRequest(method: "DELETE", url: urlString) { data, response, error in
                if error != nil { return }
                if response.statusCode == 204 { deleted = true }
                semaphore.signal()
            }
        }
        semaphore.wait()
        return deleted
    }

    func renameItem(currentPath: String, newPath: String) -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        let urlString = "https://cloud-api.yandex.net/v1/disk/resources/move?from=" + currentPath + "&path=" + newPath
        var renamed: Bool = false
        
        DispatchQueue.global().async {
            self.network.dataRequest(method: "POST", url: urlString) { data, response, error in
                if error != nil { return }
                if response.statusCode == 201 { renamed = true }
                semaphore.signal()
            }
        }
        semaphore.wait()
        return renamed
    }
    
    func close() {
        router.close()
    }

}
