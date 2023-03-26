import Foundation
import UIKit

enum Token {
    static var value: String = ""
}

enum Flag {
    static var offlineWarned: Bool = false
    static var needsReload: Bool = false
}

enum ItemListRole: String {
    case recentsViewRole
    case allFilesViewRole
    case publishedViewRole
}

enum Resources {
    enum Images {
        static let onboardingFlow: UIImage = UIImage(named: "OnboardingFlow")!
    }
    
    enum Colors {
        static let primaryAccentColor: UIColor = UIColor(red: 0.97, green: 0.81, blue: 0.27, alpha: 1.00)
    }
}

enum Text {
    enum ItemListRole {
        static let recents = Bundle.main.localizedString(forKey: "ItemListRole.Recents", value: "", table: "Localizable")
        static let allFiles = Bundle.main.localizedString(forKey: "ItemListRole.AllFiles", value: "", table: "Localizable")
        static let published = Bundle.main.localizedString(forKey: "ItemListRole.Published", value: "", table: "Localizable")
    }
    
    enum Onboarding {
        static let labelOne = Bundle.main.localizedString(forKey: "Onboarding.Label.One", value: "", table: "Localizable")
        static let labelTwo = Bundle.main.localizedString(forKey: "Onboarding.Label.Two", value: "", table: "Localizable")
        static let labelThree = Bundle.main.localizedString(forKey: "Onboarding.Label.Three", value: "", table: "Localizable")
        static let buttonNext = Bundle.main.localizedString(forKey: "Onboarding.Button.Next", value: "", table: "Localizable")
        static let buttonLogin = Bundle.main.localizedString(forKey: "Onboarding.Button.Login", value: "", table: "Localizable")
    }
    
    enum ItemList {
        static let labelOffline = Bundle.main.localizedString(forKey: "ItemList.Label.Offline", value: "", table: "Localizable")
        static let labelEmpty = Bundle.main.localizedString(forKey: "ItemList.Label.Empty", value: "", table: "Localizable")
        static let alertAuthTitle = Bundle.main.localizedString(forKey: "ItemList.AlertAuth.Title", value: "", table: "Localizable")
        static let alertAuthMessage = Bundle.main.localizedString(forKey: "ItemList.AlertAuth.Message", value: "", table: "Localizable")
        static let navigationTitleAllFiles = Bundle.main.localizedString(forKey: "ItemList.NavigationTitle.AllFiles", value: "", table: "Localizable")
        static let navigationTitleRecent = Bundle.main.localizedString(forKey: "ItemList.NavigationTitle.Recent", value: "", table: "Localizable")
        static let navigationTitlePublished = Bundle.main.localizedString(forKey: "ItemList.NavigationTitle.Published", value: "", table: "Localizable")

    }
    
    enum ItemDetails {
        static let alertShareTitle = Bundle.main.localizedString(forKey: "ItemDetails.AlertShare.Title", value: "", table: "Localizable")
        static let alertShareButtonFile = Bundle.main.localizedString(forKey: "ItemDetails.AlertShare.ButtonFile", value: "", table: "Localizable")
        static let alertShareButtonLink = Bundle.main.localizedString(forKey: "ItemDetails.AlertShare.ButtonLink", value: "", table: "Localizable")
        static let alertDeleteTitle = Bundle.main.localizedString(forKey: "ItemDetails.AlertDelete.Title", value: "", table: "Localizable")
        static let alertDeleteButton = Bundle.main.localizedString(forKey: "ItemDetails.AlertDelete.Button", value: "", table: "Localizable")
        static let alertRenameTitle = Bundle.main.localizedString(forKey: "ItemDetails.AlertRename.Title", value: "", table: "Localizable")

    }
    
    enum Account {
        static let buttonPublished = Bundle.main.localizedString(forKey: "Account.Button.Published", value: "", table: "Localizable")
        static let navigationTitleAccount = Bundle.main.localizedString(forKey: "Account.NavigationTitle", value: "", table: "Localizable")
        static let chartGbFree = Bundle.main.localizedString(forKey: "Account.Chart.GbFree", value: "", table: "Localizable")
        static let chartGbUsed = Bundle.main.localizedString(forKey: "Account.Chart.GbUsed", value: "", table: "Localizable")
    }
    
    enum Common {
        static let buttonOk = Bundle.main.localizedString(forKey: "Common.Button.Ok", value: "", table: "Localizable")
        static let buttonCancel = Bundle.main.localizedString(forKey: "Common.Button.Cancel", value: "", table: "Localizable")
        static let buttonClose = Bundle.main.localizedString(forKey: "Common.Button.Close", value: "", table: "Localizable")
        static let alertErrorTitle = Bundle.main.localizedString(forKey: "ItemList.AlertError.Title", value: "", table: "Localizable")
    }
}
