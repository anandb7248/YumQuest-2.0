//
//  MenuTVC.swift
//  YumQuest
//
//  Created by Anand Batjargal on 2/7/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import UIKit

class MenuTVC: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
