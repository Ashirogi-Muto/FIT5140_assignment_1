//
//  Constants.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 07/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import Foundation
import UIKit
struct Constants {
    static var APP_COLOR_LIGHT: UIColor { return UIColor(red: 141/255, green: 199/255, blue: 63/255, alpha: 1.0) }
    static var APP_COLOR_DARK: UIColor { return UIColor(red: 11/255, green: 148/255, blue: 70/255, alpha: 1.0) }
    static let DEFAULT_MAP_LAT = -37.830531
    static let DEFAULT_MAP_LON = 144.981197
    static let DEFAULT_ANNOTATION_NAME = "Royal Melbourne Botanicle Garden"
    static let EXHIBIT_CELL_VIEW_IDENTIFIER = "exhibitInfoCell"
    static let PLANT_CELL_VIEW_IDENTIFIER = "plantCellView"
    static let PLANT_CONTROLLER_VIEW_ID = "plantView"
    static let TREFLE_BASE_URL = "https://trefle.io/api/v1/plants/search?token=Q52QNilfW0HTwMMF1N7t0wysbnzR_5LfQB2Hdj3vNO8"
    static let PLANT_SEARCH_TABLE_CELL_IDENTIFIER = "searchViewCell"
    static let PLANT_ADD_TABLE_CELL_IDENTIFIER = "addPlantButtonCell"
    static let PLANT_VIEW_SEGUE_IDENTIDIER = "plantViewTable"
    static let EXHIBIT_DETAIL_SEGUE_IDENTIFIER = "exhibitDetailSegue"
    static let EXHIBHITION_DETAIL_PLANT_VIEW_CELL_IDENTIFIER = "exhibitDetailPlantCell"
    static let EDIT_PLANT_SEGUE_IDENTIFIER = "editPlantSegue"
    static let EDIT_EXHIBITION_SEGUE_IDENTIFIER = "editExhibitionSegue"
    static let EXHIBITION_DETAIL_STORYBOARD_IDENTIFIER = "exhibitDetailView"
}
