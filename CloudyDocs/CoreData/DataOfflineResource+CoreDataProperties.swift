import Foundation
import CoreData

extension DataOfflineResource {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataOfflineResource> {
        return NSFetchRequest<DataOfflineResource>(entityName: "DataOfflineResource")
    }

    @NSManaged public var jsonData: Data?
    @NSManaged public var path: String?
}

extension DataOfflineResource : Identifiable {

}
