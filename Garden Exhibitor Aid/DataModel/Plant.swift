//
//  Plant.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 26/08/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit

class Plant: NSObject {
    var name: String
    var plantDescription: String
    var yearDiscovered: Int
    var family: String
    var imageURL: String
    
    init(name: String, description: String, yearDiscovered: Int, family: String, imageURL: String) {
        self.name = name
        self.plantDescription = description
        self.yearDiscovered = yearDiscovered
        self.family = family
        self.imageURL = imageURL
    }
}
