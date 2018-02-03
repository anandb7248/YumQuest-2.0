//
//  RestaurantDetailsVC.swift
//  YumQuest
//
//  Created by Anand Batjargal on 1/25/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import UIKit

class RestaurantDetailsVC: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    var venue:DetailFoodVenue?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("IN RESTAURANTDETAILS VC")
        print(venue?.getDetailsOfVenueResponse?.response.venue.name ?? "UNABLE TO GET THE VALUE")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if let name = venue?.getDetailsOfVenueResponse?.response.venue.name{
            nameLabel.text = name
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
