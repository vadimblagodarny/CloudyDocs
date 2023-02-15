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
    let preview: String?
    let created: String?
    let path: String?
    let type: String?
    let mime_type: String?
    let size: String?
}

struct Download: Codable {
    let href: String?
}
