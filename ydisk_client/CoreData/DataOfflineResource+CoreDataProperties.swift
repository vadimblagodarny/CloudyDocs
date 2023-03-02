//
//  DataOfflineResource+CoreDataProperties.swift
//  ydisk_client
//
//  Created by Vadim Blagodarny on 25.02.2023.
//
//  MARK: NOT IMPLEMENTED YET

import Foundation
import CoreData


extension DataOfflineResource {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataOfflineResource> {
        return NSFetchRequest<DataOfflineResource>(entityName: "DataOfflineResource")
    }

//    @NSManaged public var path: String?
//    @NSManaged public var dataUI: [DataUI]?

}

extension DataOfflineResource : Identifiable {

}
