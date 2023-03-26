import Foundation
import UIKit
import CoreData

protocol ItemListViewModelProtocol {
    typealias Routes = OnboardingRoute & ItemDetailsRoute & ItemListRoute
    var router: Routes { get }
    var network: NetworkProtocol! { get }
    var itemListRole: ItemListRole { get }
    var diskPath: String { get }
    var onboardingViewDelegate: OnboardingViewDelegate? { get }
    var offsetCounter: Int { get set }
    
    var persistentContainer: NSPersistentContainer { get }
    var recentsFetchedResultsController: NSFetchedResultsController<DataOfflineRecent> { get }
    var allFilesFetchedResultsController: NSFetchedResultsController<DataOfflineResource> { get }
    var publishedFetchedResultsController: NSFetchedResultsController<DataOfflinePublished> { get }

    var itemsSignal: Box<[DataUI]> { get }
    var openItemSignal: Box<DataUI?> { get }
    var invokeAuthSignal: Box<Bool?> { get }
    var alertSignal: Box<String?> { get }

    init(router: Routes, network: NetworkProtocol?, role: ItemListRole, path: String)
        
    func persistentStoreLoad()
    func openOnboarding()
    func getDiskList(offset: Int)
    func processRawData(items: [RawData]) -> [DataUI]
    func openItem(item: DataUI)
}

class ItemListViewModel: ItemListViewModelProtocol {
    typealias Routes = OnboardingRoute & ItemDetailsRoute & ItemListRoute
    internal let router: Routes
    internal let network: NetworkProtocol!
    internal let itemListRole: ItemListRole
    internal var diskPath: String
    weak var onboardingViewDelegate: OnboardingViewDelegate?
    var offsetCounter: Int = 0
    
    internal let persistentContainer = NSPersistentContainer(name: "ydisk_client")
    
    internal lazy var recentsFetchedResultsController: NSFetchedResultsController<DataOfflineRecent> = {
        let fetchRequest = DataOfflineRecent.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    internal lazy var allFilesFetchedResultsController: NSFetchedResultsController<DataOfflineResource> = {
        let fetchRequest = DataOfflineResource.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "path", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()

    internal lazy var publishedFetchedResultsController: NSFetchedResultsController<DataOfflinePublished> = {
        let fetchRequest = DataOfflinePublished.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()

    var itemsSignal: Box<[DataUI]> = Box([])
    var openItemSignal: Box<DataUI?> = Box(nil)
    var invokeAuthSignal: Box<Bool?> = Box(nil)
    var alertSignal: Box<String?> = Box(nil)
    
    required init(router: Routes, network: NetworkProtocol?, role: ItemListRole, path: String) {
        self.network = network
        self.itemListRole = role
        self.diskPath = path
        self.router = router
    }
    
    func openOnboarding() {
        router.openOnboarding(opener: self)
    }
    
    func persistentStoreLoad() {
        persistentContainer.loadPersistentStores { persistentStoreDescription, error in
            if let error = error {
                print("Error loading persistent stores: \(error)")
            } else {
                do {
                    switch self.itemListRole {
                    case .recentsViewRole: try self.recentsFetchedResultsController.performFetch()
                    case .allFilesViewRole: try self.allFilesFetchedResultsController.performFetch()
                    case .publishedViewRole: try self.publishedFetchedResultsController.performFetch()
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func getDiskList(offset: Int) {
        var url: String = ""
        switch self.itemListRole {
        case .recentsViewRole:
            url = "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded?media_type=image,document,spreadsheet"
        case .allFilesViewRole:
            url = "https://cloud-api.yandex.net/v1/disk/resources?path=\(self.diskPath)&offset=\(self.offsetCounter * 20)"
            self.offsetCounter += 1
        case .publishedViewRole:
            url = "https://cloud-api.yandex.net/v1/disk/resources/public?limit=20&offset=\(self.offsetCounter * 20)"
            self.offsetCounter += 1
        }

        DispatchQueue.global().async {
            self.network.dataRequest(method: "GET", url: url) { data, response, error in
                // MARK: - Обработка ошибки соединения и подгрузка данных из Core Data
                if let error = error {
                    DispatchQueue.main.async {
                        self.alertSignal.value = error.localizedDescription
                    }
                    
                    switch self.itemListRole {
                    case .recentsViewRole:
                        let fetchRequest = self.recentsFetchedResultsController.fetchRequest
                        let context = self.persistentContainer.viewContext
                        
                        do {
                            let objects = try context.fetch(fetchRequest)
                            let items = objects.map { object in
                                return DataUI(public_key: object.public_key ?? "",
                                              public_url: object.public_url ?? "",
                                              name: object.name ?? "",
                                              preview: object.preview ?? Data(),
                                              created: object.created ?? Date(),
                                              modified: object.modified ?? Date(),
                                              path: object.path ?? "",
                                              md5: object.md5 ?? "",
                                              type: object.type ?? "",
                                              mime_type: object.mime_type ?? "",
                                              size: object.size ?? ""
                                )
                            }
                            
                            DispatchQueue.main.async {
                                self.itemsSignal.value = items
                            }
                            
                        } catch {
                            print("Core Data fetch error: \(error)")
                        }
                        
                    case .allFilesViewRole:
                        let fetchRequest = self.allFilesFetchedResultsController.fetchRequest
                        let context = self.persistentContainer.viewContext
                        
                        do {
                            let objects = try context.fetch(fetchRequest)
                            let object = objects.filter{ $0.path == self.diskPath.removingPercentEncoding }.first
                            guard let jsonData = object?.jsonData else {
                                DispatchQueue.main.async {
                                    self.itemsSignal.value = [DataUI(public_key: nil, public_url: nil, name: nil, preview: nil, created: nil, modified: nil, path: nil, md5: nil, type: nil, mime_type: "custom/offline", size: nil)]
                                }
                                return
                            }
                            let decodedJSON = try JSONDecoder().decode([DataUI].self, from: jsonData)
                            DispatchQueue.main.async {
                                self.itemsSignal.value = decodedJSON
                            }
                        } catch {
                            print("Error: \(error)")
                        }
                        
                    case .publishedViewRole:
                        let fetchRequest = self.publishedFetchedResultsController.fetchRequest
                        let context = self.persistentContainer.viewContext
                        
                        do {
                            let objects = try context.fetch(fetchRequest)
                            let items = objects.map { object in
                                return DataUI(public_key: object.public_key ?? "",
                                              public_url: object.public_url ?? "",
                                              name: object.name ?? "",
                                              preview: object.preview ?? Data(),
                                              created: object.created ?? Date(),
                                              modified: object.modified ?? Date(),
                                              path: object.path ?? "",
                                              md5: object.md5 ?? "",
                                              type: object.type ?? "",
                                              mime_type: object.mime_type ?? "",
                                              size: object.size ?? ""
                                )
                            }
                            
                            DispatchQueue.main.async {
                                self.itemsSignal.value = items
                            }
                            
                        } catch {
                            print("Core Data fetch error: \(error)")
                        }
                    }
                    return
                }

                // MARK: - Обработка ошибки авторизации
                if response.statusCode == 401 {
                    DispatchQueue.main.async {
                        self.invokeAuthSignal.value = true
                    }
                    return
                }
                
                // MARK: - Обработка полученных данных в зависимости от типа экрана
                guard let data = data else { return }
                Flag.offlineWarned = false // Сеть появилась -> сброс предупреждения об отсуствии сети

                switch self.itemListRole {
                case .recentsViewRole:
                    do {
                        let decodedJSON = try JSONDecoder().decode(ResourceList.self, from: data)
                        DispatchQueue.main.async {
                            let processedData = self.processRawData(items: decodedJSON.items ?? [])

                            // MARK: - Инициализация Core Data и очистка хранилища списка последних файлов
                            let context = self.persistentContainer.viewContext
                            let entity = NSEntityDescription.entity(forEntityName: "DataOfflineRecent", in: context)
                            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "DataOfflineRecent")
                            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                            do {
                                try self.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
                            } catch let error {
                                print("Core Data cleanup error: \(error)")
                            }
                            
                            // MARK: - Сохранение полученных данных в Core Data
                            for data in processedData {
                                let object = NSManagedObject(entity: entity!, insertInto: context)
                                object.setValue(data.public_key, forKey: "public_key")
                                object.setValue(data.public_url, forKey: "public_url")
                                object.setValue(data.name, forKey: "name")
                                object.setValue(data.preview, forKey: "preview")
                                object.setValue(data.created, forKey: "created")
                                object.setValue(data.modified, forKey: "modified")
                                object.setValue(data.path, forKey: "path")
                                object.setValue(data.md5, forKey: "md5")
                                object.setValue(data.type, forKey: "type")
                                object.setValue(data.mime_type, forKey: "mime_type")
                                object.setValue(data.size, forKey: "size")
                            }
                            
                            do {
                                try context.save()
                            } catch {
                                print("Core Data save error: \(error)")
                            }

                            // MARK: - Передача полученных данных в представление данных
                            self.itemsSignal.value = processedData
                        }
                    } catch {
                        print("JSON decoding error: \(error)")
                    }
                    
                case .allFilesViewRole:
                    do {
                        let decodedJSON = try JSONDecoder().decode(Resource.self, from: data)
                        DispatchQueue.main.async {
                            
                            let processedData = self.processRawData(items: decodedJSON._embedded?.items ?? [])
                            let path = decodedJSON.path
                            
                            // MARK: - Инициализация Core Data
                            let context = self.persistentContainer.viewContext
                            let entity = NSEntityDescription.entity(forEntityName: "DataOfflineResource", in: context)
                            let fetchRequest = self.allFilesFetchedResultsController.fetchRequest
                            var objects: [DataOfflineResource] = []

                            do {
                                objects = try context.fetch(fetchRequest)
                            } catch {
                                print("Core Data fetch error: \(error)")
                            }
                            
                            let encodedData = try? JSONEncoder().encode(processedData)
                            
                            // MARK: - Проверка на существующий объект в Core Data и сохранение нового
                            if objects.contains(where: { $0.path == decodedJSON.path }) {
                                let object = objects.filter { $0.path == decodedJSON.path }
                                context.delete(object[0])
                                do {
                                    try context.save()
                                } catch {
                                    print("Core Data save error: \(error)")
                                }
                            }
                            
                            let object = NSManagedObject(entity: entity!, insertInto: context)
                            object.setValue(path, forKey: "path")
                            object.setValue(encodedData, forKey: "jsonData")

                            do {
                                try context.save()
                            } catch {
                                print("Core Data save error: \(error)")
                            }

                            // MARK: - Передача полученных данных в представление данных
                            self.itemsSignal.value = processedData
                        }
                    } catch {
                        print(error)
                    }
                    
                case .publishedViewRole:
                    do {
                        let decodedJSON = try JSONDecoder().decode(ResourceList.self, from: data)
                        DispatchQueue.main.async {
                            let processedData = self.processRawData(items: decodedJSON.items ?? [])

                            // MARK: - Инициализация Core Data и очистка хранилища списка опубликованных файлов
                            let context = self.persistentContainer.viewContext
                            let entity = NSEntityDescription.entity(forEntityName: "DataOfflinePublished", in: context)
                            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "DataOfflinePublished")
                            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                            do {
                                try self.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
                            } catch let error {
                                print("Core Data cleanup error: \(error)")
                            }
                            
                            // MARK: - Сохранение полученных данных в Core Data
                            for data in processedData {
                                let object = NSManagedObject(entity: entity!, insertInto: context)
                                object.setValue(data.public_key, forKey: "public_key")
                                object.setValue(data.public_url, forKey: "public_url")
                                object.setValue(data.name, forKey: "name")
                                object.setValue(data.preview, forKey: "preview")
                                object.setValue(data.created, forKey: "created")
                                object.setValue(data.modified, forKey: "modified")
                                object.setValue(data.path, forKey: "path")
                                object.setValue(data.md5, forKey: "md5")
                                object.setValue(data.type, forKey: "type")
                                object.setValue(data.mime_type, forKey: "mime_type")
                                object.setValue(data.size, forKey: "size")
                            }
                            
                            do {
                                try context.save()
                            } catch {
                                print("Core Data save error: \(error)")
                            }

                            // MARK: - Передача полученных данных в представление данных
                            self.itemsSignal.value = processedData
                        }
                    } catch {
                        print("JSON decoding error: \(error)")
                    }

                }
            }
        }
    }
    
    func processRawData(items: [RawData]) -> [DataUI] {
        let dateFormatterIn = DateFormatter()
        dateFormatterIn.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        var sizeString: String = ""
        let sizeFormatter = ByteCountFormatter()
        sizeFormatter.allowedUnits = [.useAll]
        
        return items.map {
            var previewImage = Data()
            if $0.size == nil { sizeString = "" } else { sizeString = sizeFormatter.string(fromByteCount: $0.size ?? 0) }
            if !Flag.offlineWarned { previewImage = self.network.loadPreviewImage(url: $0.preview ?? "") }
            return DataUI(public_key: $0.public_key ?? "",
                          public_url: $0.public_url ?? "",
                          name: $0.name ?? "",
                          preview: previewImage,
                          created: dateFormatterIn.date(from: $0.created ?? "") ?? Date(),
                          modified: dateFormatterIn.date(from: $0.modified ?? "") ?? Date(),
                          path: $0.path ?? "",
                          md5: $0.md5 ?? "",
                          type: $0.type ?? "",
                          mime_type: $0.mime_type ?? "",
                          size: sizeString)
        }
    }
    
    func openItem(item: DataUI) {
        guard item.type == "dir" else {
            router.openItemDetails(item: item, with: PushTransition())
            return
        }
        router.openItemList(role: ItemListRole.allFilesViewRole, path: item.path!.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
    }
}

extension ItemListViewModel: OnboardingViewDelegate {
    func authComplete() {
        getDiskList(offset: offsetCounter * 20)
    }
}
