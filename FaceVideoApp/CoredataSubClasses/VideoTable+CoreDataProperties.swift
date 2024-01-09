//
//  VideoTable+CoreDataProperties.swift
//  FaceVideoApp
//
//  Created by Najran Emarah on 27/06/1445 AH.
//
//

import Foundation
import CoreData


extension VideoTable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoTable> {
        return NSFetchRequest<VideoTable>(entityName: "VideoTable")
    }

    @NSManaged public var video: Data?
    @NSManaged public var tag: String?
    @NSManaged public var duration: Float

}

extension VideoTable : Identifiable {

}
