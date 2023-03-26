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
    let public_key: String?
    let public_url: String?
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

struct DataUI: Codable {
    let public_key: String?
    let public_url: String?
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
