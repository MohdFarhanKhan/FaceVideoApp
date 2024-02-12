//
//  VideoTable+CoreDataProperties.swift
//  FaceVideoApp
//
//  Created by Najran Emarah on 01/07/1445 AH.
//
//

import Foundation
import CoreData


extension VideoTable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoTable> {
        return NSFetchRequest<VideoTable>(entityName: "VideoTable")
    }

    @NSManaged public var duration: Float
    @NSManaged public var frontImage: String?
    @NSManaged public var id: UUID?
    @NSManaged public var tag: String?
    @NSManaged public var video: String?

}

extension VideoTable : Identifiable {

}
