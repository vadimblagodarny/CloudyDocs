//
//  DataOfflineItem+CoreDataProperties.swift
//  ydisk_client
//
//  Created by Vadim Blagodarny on 25.02.2023.
//
//

import Foundation
import CoreData


extension DataOfflineItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataOfflineItem> {
        return NSFetchRequest<DataOfflineItem>(entityName: "DataOfflineItem")
    }

    @NSManaged public var md5: String?
    @NSManaged public var data: Data?

}

extension DataOfflineItem : Identifiable {

}
