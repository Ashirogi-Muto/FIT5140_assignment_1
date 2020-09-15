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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Customize imageView like you need
        exhibitImage.frame = CGRect(x: exhibitImage.frame.origin.x, y: exhibitImage.frame.origin.y, width: 56, height: 55.5)
        exhibitImage.contentMode = UIView.ContentMode.scaleAspectFit
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
