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
    var imageURLs : [String] = [String]()
    var firstReview = false
    
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    // Image
    @IBOutlet weak var imageScrollView: UIScrollView!
    var imageArray = [UIImage]()
    // Image
    
    @IBOutlet weak var reviewsTable: UITableView!
    
    var itemRatingsReviewsRef:DatabaseReference? = Database.database().reference().child("ItemRatingReviews")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fill image url array
        getImagesURLs()
        // Fill image array
        //getImages()
        
        if let name = venueName{
            venueNameLabel.text = name
        }
        if let item = menuItem{
            itemNameLabel.text = item.name
            if let price = item.price{
                priceLabel.text = "$" + price
            }else{
                priceLabel.text = "NA"
            }
            
            descriptionLabel.text = item.description
            descriptionLabel.sizeToFit()
            
            itemRatingsReviewsRef?.child(item.entryId!).observe(.value, with: { (snapshot) in
                if !self.firstReview{
                    if snapshot.exists(){
                        let value = snapshot.value as! [String : AnyObject]
                        let avgRating = value["averageRating"] as! Double
                        let numberOfReviews = value["count"] as! Int
                        self.numberOfReviewsLabel.text = String(numberOfReviews) + " Reviews"
                        self.ratingLabel.text = String(format:"%.1f",avgRating)
                    }
                }
            })
        }
        
        self.reloadViewDidLoad()
    }
    
    func appendImage(img : UIImage){
        imageArray.append(img)
        
        imageScrollView.frame = self.imageScrollView.frame
        
        for i in 0..<imageArray.count{
            let imageView = UIImageView()
            imageView.image = imageArray[i]
            imageView.contentMode = .scaleAspectFit
            let xPosition = self.imageScrollView.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width:self.imageScrollView.frame.width, height:self.imageScrollView.frame.height)
            
            imageScrollView.contentSize.width = imageScrollView.frame.width * CGFloat(i + 1)
            imageScrollView.addSubview(imageView)
        }
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
                                //let imageURL = reviewDict["imageURL"] as! String
                                
                                self.reviews.append(review)
                                self.dates.append(date)
                                //self.imageURLs.append(imageURL)
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
    
    func getImagesURLs() {
        if let item = menuItem{
            if let itemID = item.entryId{
                itemRatingsReviewsRef?.child(itemID).child("userIDsReviews").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if snapshot.exists(){
                        for userIDKey in snapshot.children{
                            let userIDs = userIDKey as! DataSnapshot
                            
                            for singleUserReview in userIDs.children{
                                let singleReview = singleUserReview as! DataSnapshot
                                let reviewDict = singleReview.value as! [String : AnyObject]
                                print("-----------------------------------")
                                print(reviewDict["imageURL"])
                                
                                let imageURL = reviewDict["imageURL"] as! String
                                
                                URLSession.shared.dataTask(with: NSURL(string: imageURL)! as URL, completionHandler: { (data, response, error) -> Void in
                                    
                                    let image = UIImage(data: data!)
                                    
                                    DispatchQueue.main.async {
                                        self.appendImage(img: image!)
                                    }
                                }).resume()
                                
                            }
                        }
                    }
                })
                
            }
        }
        /*
        //imageArray = [#imageLiteral(resourceName: "emptyStar"),#imageLiteral(resourceName: "highlightedStar")]
        
        //imageScrollView.frame =
        
        for i in 0..<imageArray.count{
            let imageView = UIImageView()
            imageView.image = imageArray[i]
            //imageView.contentMode = .scaleAspectFit
            imageView.contentMode = .scaleToFill
            let xPosition = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width:self.view.frame.width, height:self.view.frame.height)
            
            imageScrollView.contentSize.width = imageScrollView.frame.width * CGFloat(i + 1)
            imageScrollView.addSubview(imageView)
        }
        */
    }
    
    func getImages() {
        for imageURL in imageURLs{
            URLSession.shared.dataTask(with: NSURL(string: imageURL)! as URL, completionHandler: { (data, response, error) -> Void in
                
                let image = UIImage(data: data!)
                self.imageArray.append(image!)
            }).resume()
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            for i in 0..<self.imageArray.count{
                let imageView = UIImageView()
                imageView.image = self.imageArray[i]
                //imageView.contentMode = .scaleAspectFit
                imageView.contentMode = .scaleToFill
                let xPosition = self.view.frame.width * CGFloat(i)
                imageView.frame = CGRect(x: xPosition, y: 0, width:self.view.frame.width, height:self.view.frame.height)
                
                self.imageScrollView.contentSize.width = self.imageScrollView.frame.width * CGFloat(i + 1)
                self.imageScrollView.addSubview(imageView)
            }
        })
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
