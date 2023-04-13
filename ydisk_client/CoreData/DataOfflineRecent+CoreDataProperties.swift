import Foundation
import CoreData

extension DataOfflineRecent {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataOfflineRecent> {
        return NSFetchRequest<DataOfflineRecent>(entityName: "DataOfflineRecent")
    }

    @NSManaged public var created: Date?
    @NSManaged public var md5: String?
    @NSManaged public var mime_type: String?
    @NSManaged public var modified: Date?
    @NSManaged public var name: String?
    @NSManaged public var path: String?
    @NSManaged public var preview: Data?
    @NSManaged public var size: String?
    @NSManaged public var type: String?
    @NSManaged public var public_key: String?
    @NSManaged public var public_url: String?
}

extension DataOfflineRecent : Identifiable {

}
