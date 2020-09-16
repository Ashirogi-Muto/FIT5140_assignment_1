//
//  ExhibitDetailPantTableViewCell.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 16/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit

class ExhibitDetailPantTableViewCell: UITableViewCell {

    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var plantScientificName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
