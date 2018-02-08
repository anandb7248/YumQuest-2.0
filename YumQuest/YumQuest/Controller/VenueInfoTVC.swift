//
//  VenueInfoTVC.swift
//  YumQuest
//
//  Created by Anand Batjargal on 12/22/17.
//  Copyright © 2017 AnandBatjargal. All rights reserved.
//

import UIKit

class VenueInfoTVC: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var pricetierLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hasMenuIndicator: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
