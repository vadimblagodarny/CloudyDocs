import Foundation
import UIKit

struct ResourceList: Codable {
    let sort: String?
    let path: String?
    let items: [RawData]?
}

struct Resource: Codable {
    let public_key: String?
    let _embedded: ResourceList?
    let name: String?
    let created: String?
    let public_url: String?
    let modified: String?
    let path: String?
    let type: String?
}

struct RawData: Codable {
    let name: String?
    let preview: String?
    let created: String?
    let modified: String?
    let path: String?
    let md5: String?
    let type: String?
    let mime_type: String?
    let size: Int64?
}

struct DataUI {
    let name: String?
    let preview: Data?
    let created: Date?
    let modified: Date?
    let path: String?
    let md5: String?
    let type: String?
    let mime_type: String?
    let size: String?
}

// MARK: DataUI class for CoreData compatibility
//public class DataUI: NSObject, NSSecureCoding {
//    public static var supportsSecureCoding: Bool = true
//
//    var name: String?
//    var preview: Data?
//    var created: String?
//    var modified: String?
//    var path: String?
//    var md5: String?
//    var type: String?
//    var mime_type: String?
//    var size: String?
//
//    init(name: String, preview: Data, created: String, modified: String, path: String, md5: String, type: String, mime_type: String, size: String) {
//        self.name = name
//        self.preview = preview
//        self.created = created
//        self.modified = modified
//        self.path = path
//        self.md5 = md5
//        self.type = type
//        self.mime_type = mime_type
//        self.size = size
//    }
//
//    required public init?(coder: NSCoder) {
//        coder.encode(name, forKey: "name")
//        coder.encode(preview, forKey: "preview")
//        coder.encode(created, forKey: "created")
//        coder.encode(modified, forKey: "name")
//        coder.encode(path, forKey: "path")
//        coder.encode(md5, forKey: "md5")
//        coder.encode(type, forKey: "type")
//        coder.encode(mime_type, forKey: "mime_type")
//        coder.encode(size, forKey: "size")
//    }
//
//    public func encode(with coder: NSCoder) {
//        name = coder.decodeObject(of: NSString.self, forKey: "name") as String? ?? ""
//        preview = coder.decodeObject(of: NSData.self, forKey: "preview") as Data? ?? Data()
//        created = coder.decodeObject(of: NSString.self, forKey: "created") as String? ?? ""
//        modified = coder.decodeObject(of: NSString.self, forKey: "modified") as String? ?? ""
//        path = coder.decodeObject(of: NSString.self, forKey: "path") as String? ?? ""
//        md5 = coder.decodeObject(of: NSString.self, forKey: "md5") as String? ?? ""
//        type = coder.decodeObject(of: NSString.self, forKey: "type") as String? ?? ""
//        mime_type = coder.decodeObject(of: NSString.self, forKey: "mime_type") as String? ?? ""
//        size = coder.decodeObject(of: NSString.self, forKey: "size") as String? ?? ""
//    }
//}
