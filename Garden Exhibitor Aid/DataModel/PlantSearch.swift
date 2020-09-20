//
//  PlantSearch.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 08/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import Foundation

//Decodable class to handle plant search api data
struct PlantSearchResult: Decodable {
    let data: [PlantSearchItem]?
}

struct PlantSearchItem: Decodable {
    let common_name: String?
    let year: Int16?
    let image_url: String?
    let scientific_name: String?
    let family: String?
}
