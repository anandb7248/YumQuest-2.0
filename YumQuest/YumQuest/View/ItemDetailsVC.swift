//
//  ItemDetails.swift
//  YumQuest
//
//  Created by Anand Batjargal on 2/20/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import UIKit
import Firebase

class ItemDetailsVC: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var venueName : String?
    var menuItem : MenuItem?
    var reviews : [String]?
    
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    
    @IBOutlet weak var reviewsTable: UITableView!
    
    var ref:DatabaseReference? = Database.database().reference().child("ItemRatings")
    var reviewsRef:DatabaseReference? = Database.database().reference().child("ItemReviews")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadViewDidLoad()
    }
    
    func reloadViewDidLoad(){
        if let name = venueName{
            venueNameLabel.text = name
        }
        if let item = menuItem{
            itemNameLabel.text = item.name
            priceLabel.text = "$" + item.price!
            descriptionLabel.text = item.description
            ref?.child(item.entryId!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as! [String : AnyObject]
                let rating = value["Rating"] as! Double
                let numberOfReviews = value["NumberOfRatings"] as! Int
                
                self.numberOfReviewsLabel.text = String(numberOfReviews) + " Reviews"
                
                if rating == 0.0 {
                    self.ratingLabel.text = "NA"
                }else if rating == 10.0 {
                    self.ratingLabel.text = "10"
                }else{
                    self.ratingLabel.text = String(format:"%.1f",rating)
                }
            })
            
            reviewsRef?.child(item.entryId!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.exists(){
                    let value = snapshot.value as! [String : String]
                    self.reviews = Array(value.values)
                    self.reviewsTable.reloadData()
                }
            })
        }
        // Reload the table for the menu items to display updated ratings
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        
        // Obtain all of the reviews for the item from Firebase
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TABLE FUNCTIONS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let reviews = self.reviews {
            return reviews.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell") as! ReviewTVC
        
        if let reviews = self.reviews{
            cell.reviewLabel.text = reviews[indexPath.row]
        }
        
        return cell
    }
    // TABLE FUNCTIONCS
    
    func updateRatingLabel(rating:Double) {
        if rating == 0.0 {
            self.ratingLabel.text = "NA"
        }else if rating == 10.0{
            self.ratingLabel.text = "10"
        }else{
            self.ratingLabel.text = String(format:"%.1f", rating)
        }
    }
    
    // Unwind segue
    @IBAction func unwindToItemDetails(segue: UIStoryboardSegue) {}
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rateItem"{
            let destVC = segue.destination as! ReviewItemVC
            destVC.name = venueName
            destVC.item = self.menuItem
        }
    }

}
