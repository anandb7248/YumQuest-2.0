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
    var dates : [String] = [String]()
    var reviews : [String] = [String]()
    var firstReview = false
    
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    
    @IBOutlet weak var reviewsTable: UITableView!
    
    var itemRatingsReviewsRef:DatabaseReference? = Database.database().reference().child("ItemRatingReviews")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = venueName{
            venueNameLabel.text = name
        }
        if let item = menuItem{
            itemNameLabel.text = item.name
            priceLabel.text = "$" + item.price!
            descriptionLabel.text = item.description
            
            /*
            itemRatingsReviewsRef?.child(item.entryId!).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    self.firstReview = false
                }
            })
            */
            
            itemRatingsReviewsRef?.child(item.entryId!).observe(.value, with: { (snapshot) in
                if !self.firstReview{
                    if snapshot.exists(){
                        let value = snapshot.value as! [String : AnyObject]
                        let avgRating = value["averageRating"] as! Double
                        let numberOfReviews = value["count"] as! Int
                        self.numberOfReviewsLabel.text = String(numberOfReviews) + " Reviews"
                        self.ratingLabel.text = String(format:"%.1f",avgRating)
                        
                        print("------------COUNT-RATING------------")
                        print(numberOfReviews)
                        print(avgRating)
                    }
                }
            })
            /*
            // Fill the reviews table
            itemRatingsReviewsRef?.child(item.entryId!).child("userIDsReviews").observe(.value, with:{ (snapshot) in
                if !self.firstReview{
                    if snapshot.exists(){
                        self.dates = [String]()
                        self.reviews = [String]()
                    
                        for userIDKey in snapshot.children{
                            let userIDs = userIDKey as! DataSnapshot
                        
                            for singleUserReview in userIDs.children{
                                let singleReview = singleUserReview as! DataSnapshot
                                let reviewDict = singleReview.value as! [String : AnyObject]
                                let review = reviewDict["review"] as! String
                                let date = reviewDict["date"] as! String
                            
                                self.reviews.append(review)
                                self.dates.append(date)
                            }
                        }
                    
                        self.reviewsTable.reloadData()
                    }
                }
            })
            */
        }
        
        self.reloadViewDidLoad()
    }
    
    func reloadViewDidLoad(){
        self.reviews = [String]()
        self.dates = [String]()
        
        if let item = menuItem{
            if let itemID = item.entryId{
                itemRatingsReviewsRef?.child(itemID).child("userIDsReviews").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if snapshot.exists(){
                        for userIDKey in snapshot.children{
                            let userIDs = userIDKey as! DataSnapshot
                            
                            for singleUserReview in userIDs.children{
                                let singleReview = singleUserReview as! DataSnapshot
                                let reviewDict = singleReview.value as! [String : AnyObject]
                                let review = reviewDict["review"] as! String
                                let date = reviewDict["date"] as! String
                                
                                self.reviews.append(review)
                                self.dates.append(date)
                            }
                        }
                        
                        self.reviewsTable.reloadData()
                    }
                })
            }
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
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell") as! ReviewTVC
        
        cell.reviewLabel.text = reviews[indexPath.row]
        
        return cell
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
