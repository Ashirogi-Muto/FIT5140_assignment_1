//
//  Exhibition.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 26/08/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import MapKit

class ExhibitionClass: NSObject, MKAnnotation {
    var name: String
    var exhibitionDescription: String
    var plants: [PlantClass]
    var coordinate: CLLocationCoordinate2D
    
    init(name: String, description: String, plants: [PlantClass], coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.exhibitionDescription = description
        self.plants = plants
        self.coordinate = coordinate
    }
    
    var title: String? {
        return name
    }
}
