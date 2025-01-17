//
//  Plant+CoreDataProperties.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 20/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//
//

import Foundation
import CoreData


extension Plant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Plant> {
        return NSFetchRequest<Plant>(entityName: "Plant")
    }

    @NSManaged public var family: String?
    @NSManaged public var id: UUID?
    @NSManaged public var imageUrl: String?
    @NSManaged public var name: String?
    @NSManaged public var scientificName: String?
    @NSManaged public var yearDiscovered: Int16
    @NSManaged public var ofExhibition: Exhibition?

}
