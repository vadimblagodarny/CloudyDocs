import Foundation
import UIKit

enum Token {
    static var value: String = ""
}

enum ItemListRole: String {
    case recentsViewRole = "Последние"
    case allFilesViewRole = "Все Файлы"
//    case publishedViewRole = "Опубликованные"
}

enum Resources {
    enum Images {
        static let onboardingBackground: UIImage = UIImage(named: "OnboardingBackground")!
    }
    
    enum Colors {
        static let primaryAccentColor: UIColor = UIColor(red: 0.36, green: 0.57, blue: 0.70, alpha: 1.00)
    }
}
