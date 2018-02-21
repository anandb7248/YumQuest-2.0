//
//  ItemDetails.swift
//  YumQuest
//
//  Created by Anand Batjargal on 2/20/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import UIKit

class ItemDetailsVC: UIViewController {
    var venueName : String?
    var menuItem : MenuItem?
    
    @IBOutlet weak var venueNameLabel: UILabel!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let name = venueName{
            venueNameLabel.text = name
        }
        if let item = menuItem{
            itemNameLabel.text = item.name
            priceLabel.text = item.price
            descriptionLabel.text = item.description
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
