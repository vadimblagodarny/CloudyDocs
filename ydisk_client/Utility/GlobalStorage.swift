import Foundation
import UIKit

enum Token {
    static var value: String = ""
}

enum State {
    static var offlineWarned: Bool = false
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
        static let primaryAccentColor: UIColor = UIColor(red: 0.97, green: 0.81, blue: 0.27, alpha: 1.00)
    }
}
