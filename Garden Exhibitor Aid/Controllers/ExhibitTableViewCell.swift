//
//  ExhibitTableViewCell.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 01/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit

class ExhibitTableViewCell: UITableViewCell {
    
    @IBOutlet weak var exhibitName: UILabel!
    @IBOutlet weak var exhibitDescription: UILabel!
    
    @IBOutlet weak var exhibitImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
