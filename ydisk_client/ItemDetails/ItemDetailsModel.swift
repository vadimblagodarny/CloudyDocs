import Foundation
import UIKit

struct ItemUI {
    var name: String?
    var data: Data?
    var created: Date?
    var mime_type: String?
    var size: String?
}

struct Download: Codable {
    let href: String?
}

struct Link: Codable {
    let href: String?
    let method: String?
    let templated: Bool?
}
