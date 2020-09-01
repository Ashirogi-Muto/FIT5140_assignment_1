//
//  ExhibitAnnotation.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 31/08/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import Foundation
import MapKit

class ExhibitAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    let id: UUID

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, id: UUID) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.id = id
        super.init()
    }
}
