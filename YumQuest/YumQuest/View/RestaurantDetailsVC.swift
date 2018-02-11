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
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var viewMenuButton: UIButton!
    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    
    var detailFoodVenue:DetailFoodVenue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let venue = detailFoodVenue?.getDetailsOfVenueResponse?.response.venue {
            nameLabel.text = venue.name
            ratingLabel.text = getFormattedRating(ratingDouble: venue.rating)
            ratingLabel.backgroundColor = hexStringToUIColor(hex: venue.ratingColor)
            phoneNumberLabel.text = venue.contact.formattedPhone
            if let numReviews = venue.ratingSignals{
                numberOfReviewsLabel.text = String(numReviews) + " Reviews"
            }
            if let hasMenu = venue.hasMenu {
                if(hasMenu){
                    viewMenuButton.isHidden = false
                }else{
                    viewMenuButton.isHidden = true
                }
            }else{
                viewMenuButton.isHidden = true
            }
            if let address = venue.location.address {
                if let city = venue.location.city {
                    if let state = venue.location.state {
                        addressLabel.text = address + ", " + city + ", " + state
                    }else{
                        addressLabel.text = address + ", " + city
                    }
                }else{
                    addressLabel.text = address
                }
            }else{
                addressLabel.text = "Address Unknown"
            }
        }
        
        if let id = detailFoodVenue?.id{
            print("Going to Menu Retriever")
            menuRetriever(id: id)
        }
    }
    
    // Helper Function - Menu Retriever
    func menuRetriever(id : String){
        // Use the incoming id to create a foursquare api request url
        let foursquareGetMenuURL = URL(string: "https://api.foursquare.com/v2/venues/\(id)/menu?&client_id=RT1SBOGHXRKX5KCQIAKDKDIOMHIYEDSPHXPHJTYYRPDUHVCX&client_secret=QNAZYTA3UEMCGMZQBZTB5FUHSQHYXH0N4KAQ4J5TOF354DKL&v=20180121")
        
        // "https://api.foursquare.com/v2/venues/5010936ce4b0abd8740f8fb7?&client_id=RT1SBOGHXRKX5KCQIAKDKDIOMHIYEDSPHXPHJTYYRPDUHVCX&client_secret=QNAZYTA3UEMCGMZQBZTB5FUHSQHYXH0N4KAQ4J5TOF354DKL&v=20180121"
        
        print("Get a Venue's Menu Request")
        print(foursquareGetMenuURL!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func viewMenuPressed(_ sender: Any) {
        //performSegue(withIdentifier: "showMenu", sender: nil)
    }
    
    func getFormattedRating(ratingDouble : Double?) -> String{
        if let rating = ratingDouble {
            let ratingStr = String(Double(round(10*rating)/10))
            return ratingStr
        }else {
            return "NA"
        }
    }
    
    func hexStringToUIColor (hex:String?) -> UIColor {
        guard let hex = hex else {
            return UIColor.white
        }
        
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showMenu"){
            let destVC = segue.destination as! MenuDetailsVC
            destVC.restaurantDetails = detailFoodVenue
        }
    }
}

