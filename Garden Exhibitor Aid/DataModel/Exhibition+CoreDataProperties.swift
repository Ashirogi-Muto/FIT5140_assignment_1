//
//  Exhibition+CoreDataProperties.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 30/08/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//
//

import Foundation
import CoreData


extension Exhibition {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exhibition> {
        return NSFetchRequest<Exhibition>(entityName: "Exhibition")
    }

    @NSManaged public var name: String?
    @NSManaged public var exhibitionDescription: String?
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var id: UUID?
    @NSManaged public var plants: NSSet?

}

// MARK: Generated accessors for plants
extension Exhibition {

    @objc(addPlantsObject:)
    @NSManaged public func addToPlants(_ value: Plant)

    @objc(removePlantsObject:)
    @NSManaged public func removeFromPlants(_ value: Plant)

    @objc(addPlants:)
    @NSManaged public func addToPlants(_ values: NSSet)

    @objc(removePlants:)
    @NSManaged public func removeFromPlants(_ values: NSSet)

}
