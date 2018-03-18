//
//  ReviewTVC.swift
//  YumQuest
//
//  Created by Anand Batjargal on 3/12/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import UIKit

class ReviewTVC: UITableViewCell {

    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
