//
//  ReviewItemVC.swift
//  YumQuest
//
//  Created by Anand Batjargal on 3/10/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import UIKit
import Firebase

class ReviewItemVC: UIViewController,
                    UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var name : String?
    var item : MenuItem?
    var itemRatingsReviewsRef : DatabaseReference = Database.database().reference().child("ItemRatingReviews")
    // Firebase Storage
    let imageStorageRef = Storage.storage().reference()
    var rating : String = ""
    var newCount : Int = 0
    var uniqueReviewID : String?

    @IBOutlet weak var starRatingControl: RatingControl!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var reviewTF: UITextField!
    @IBOutlet weak var addImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = name{
            venueNameLabel.text = name
        }
        if let item = item{
            itemNameLabel.text = item.name
        }
        
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Image - Photo Library
    @IBAction func uploadPicturePressed(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            addImage.image = image
        }else{
            // Error message
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // Hide keyboard when return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        reviewTF.resignFirstResponder()
        return true
    }

    @IBAction func submitReview(_ sender: Any) {
        // Get the current chosen star rating (1 - 5 scale)
        let usersRating = Double(starRatingControl.rating)
        
        // Write the review to the database
        //itemReviewsRef.child((item?.entryId)!).setValue(reviewTF.text)
        // Get the current authorized user's id
        let userID = Auth.auth().currentUser?.uid
        print(userID!)
        
        // Get the itemId
        if let itemID = item?.entryId{
            print("----------SubmitReviewPressed------------")
            //print(usersRating)
            //print(reviewTF.text!)
            // Get reference to the item
            let itemRef = self.itemRatingsReviewsRef.child(itemID)
            
            // Check if the item currently exists
            itemRatingsReviewsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                // If data associated with the item already exists
                if snapshot.hasChild(itemID){
                    var newTotal = 0.0
                    var newCount = 0
                    var newAverage = 0.0
                    
                    // Increment previous count
                    itemRef.child("count").observeSingleEvent(of: .value, with: { snapshot in
                        let value = snapshot.value as! Int
                        newCount = value + 1
                        itemRef.child("count").setValue(newCount)
                    })
                    // Set new total
                    itemRef.child("totalRatings").observeSingleEvent(of: .value, with: { snapshot in
                        let value = snapshot.value as! Double
                        newTotal = value + usersRating
                        itemRef.child("totalRatings").setValue(newTotal)
                    })
                    // Set new average
                    itemRef.child("averageRating").observeSingleEvent(of: .value, with: { snapshot in
                        //let value = snapshot.value as! Double
                        newAverage = newTotal/Double(newCount)
                        itemRef.child("averageRating").setValue(newAverage)
                    })
                    // Set new user review
                    if let userID = userID{
                        let newUserReviewRef = itemRef.child("userIDsReviews").child(userID).childByAutoId()
                        print("UNIQUE KEY")
                        print(newUserReviewRef.key)
                        self.uniqueReviewID = newUserReviewRef.key
                        // Set the user review date
                        newUserReviewRef.child("date").setValue(self.getDate())
                        // Set the user review
                        newUserReviewRef.child("review").setValue(self.reviewTF.text)
                        // Set the user review rating
                        newUserReviewRef.child("rating").setValue(usersRating)
                        
                        let imageRef = self.imageStorageRef.child("image").child(itemID).child(userID).child(self.uniqueReviewID!)
                        print("-----------------------------------------------------------------")
                        print(self.uniqueReviewID!)
                        self.uploadImage(self.addImage.image!, at: imageRef, completion: { (downloadURL) in
                            guard let downloadURL = downloadURL else {
                                return
                            }
                            
                            let urlString = downloadURL.absoluteString
                            print("image url: \(urlString)")
                            
                            // Store imageURLString to the review
                            // Set the user image url
                            itemRef.child("userIDsReviews").child(userID).child(self.uniqueReviewID!).child("imageURL").setValue(urlString)
                        })
                    }
                    self.performSegue(withIdentifier: "unwindToItemDetails", sender: nil)
                }else{
                    // Set the count
                    itemRef.child("count").setValue(1)
                    // Set the total
                    itemRef.child("totalRatings").setValue(Int(usersRating))
                    // Set the average rating
                    itemRef.child("averageRating").setValue(usersRating)
                    // Set information regarding user's review
                    // Check if userID lead to an actual value
                    if let userID = userID{
                        let newUserReviewRef = itemRef.child("userIDsReviews").child(userID).childByAutoId()
                        print("UNIQUE KEY")
                        print(newUserReviewRef.key)
                        self.uniqueReviewID = newUserReviewRef.key
                        // Set the user review date
                        newUserReviewRef.child("date").setValue(self.getDate())
                        // Set the user review
                        newUserReviewRef.child("review").setValue(self.reviewTF.text)
                        // Set the user review rating
                        newUserReviewRef.child("rating").setValue(usersRating)
                        
                        let imageRef = self.imageStorageRef.child("image").child(itemID).child(userID).child(self.uniqueReviewID!)
                        print("-----------------------------------------------------------------")
                        print(self.uniqueReviewID!)
                        self.uploadImage(self.addImage.image!, at: imageRef, completion: { (downloadURL) in
                            guard let downloadURL = downloadURL else {
                                return
                            }
                            
                            let urlString = downloadURL.absoluteString
                            print("image url: \(urlString)")
                            
                            // Store imageURLString to the review
                            // Set the user image url
                            itemRef.child("userIDsReviews").child(userID).child(self.uniqueReviewID!).child("imageURL").setValue(urlString)
                        })
                    }
                    self.performSegue(withIdentifier: "unwindToItemDetails", sender: true)
                }
            })
        }
    }
    
    // Upload image to Firebase Storage
    func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        // 1
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        
        // 2
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            // 3
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            // 4
            completion(metadata?.downloadURL())
        })
    }
    
    // Get date function
    func getDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        let result = formatter.string(from: date)
        
        return result
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let send = sender{
            let firstReview = send as! Bool
            
            if firstReview{
                let dest = segue.destination as! ItemDetailsVC
                dest.ratingLabel.text = String(starRatingControl.rating)
                dest.numberOfReviewsLabel.text = "1 Review"
                dest.firstReview = true
                dest.reloadViewDidLoad()
            }
        }else{
            let dest = segue.destination as! ItemDetailsVC
            dest.firstReview = false
            dest.reloadViewDidLoad()
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
