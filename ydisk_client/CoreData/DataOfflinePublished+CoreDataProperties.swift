import Foundation
import CoreData

extension DataOfflinePublished {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataOfflinePublished> {
        return NSFetchRequest<DataOfflinePublished>(entityName: "DataOfflinePublished")
    }

    @NSManaged public var public_url: String?
    @NSManaged public var created: Date?
    @NSManaged public var md5: String?
    @NSManaged public var mime_type: String?
    @NSManaged public var modified: Date?
    @NSManaged public var name: String?
    @NSManaged public var path: String?
    @NSManaged public var preview: Data?
    @NSManaged public var public_key: String?
    @NSManaged public var size: String?
    @NSManaged public var type: String?
}

extension DataOfflinePublished : Identifiable {

}
