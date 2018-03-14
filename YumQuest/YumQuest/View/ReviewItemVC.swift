//
//  ReviewItemVC.swift
//  YumQuest
//
//  Created by Anand Batjargal on 3/10/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import UIKit
import Firebase

class ReviewItemVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate {
    
    var name : String?
    var item : MenuItem?
    // Firebase reference
    var itemRatingsRef : DatabaseReference = Database.database().reference().child("ItemRatings")
    var itemReviewsRef : DatabaseReference = Database.database().reference().child("ItemReviews")

    @IBOutlet weak var ratingPicker: UIPickerView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var reviewTF: UITextField!
    
    let ratingOptions = ["1", "2", "3", "4", "5", "6","7","8","9","10"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print item id
        print("ITEM ID:")
        print(item?.entryId!)
        
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ratingOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Avenir Black", size: 16.0)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = ratingOptions[row]
        pickerLabel?.textColor = UIColor.white
        
        return pickerLabel!
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ratingOptions.count
    }
    
    // Hide keyboard when return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        reviewTF.resignFirstResponder()
        return true
    }

    
    @IBAction func submitReview(_ sender: Any) {
        let usersRating = Double(ratingPicker.selectedRow(inComponent: 0)) + 1.0
        
        print("----------SubmitReviewPressed------------")
        print(reviewTF.text!)
        
        // Write the review to the database
        //itemReviewsRef.child((item?.entryId)!).setValue(reviewTF.text)
        // Get the current authorized user's id
        let userID = Auth.auth().currentUser?.uid
        print(userID!)
        // Append the user review to Firebase
        itemReviewsRef.child((item?.entryId)!).child(userID!).setValue(reviewTF.text)
        
        itemRatingsRef.child((item?.entryId)!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! [String : AnyObject]
            
            let curRating = value["Rating"] as! Double
            let curNumberOfRatings = value["NumberOfRatings"] as! Int
            let curTotalRatings = value["TotalRatings"] as! Int
            
            if curRating == 0.0{
                self.itemRatingsRef.child((self.item?.entryId)!).setValue(["NumberOfRatings" : 1, "TotalRatings": Int(usersRating), "Rating":usersRating])
                self.performSegue(withIdentifier: "unwindToItemDetails", sender: usersRating)
            }else{
                let newNumberOfRatings = curNumberOfRatings + 1
                let newTotalRatings = Double(curTotalRatings) + usersRating
                let newRating = newTotalRatings / Double(newNumberOfRatings)
                self.itemRatingsRef.child((self.item?.entryId)!).setValue(["NumberOfRatings" : newNumberOfRatings, "TotalRatings": newTotalRatings, "Rating": newRating])
                self.performSegue(withIdentifier: "unwindToItemDetails", sender: usersRating)
            }
        })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if sender != nil {
            let dest = segue.destination as! ItemDetailsVC
            //dest.updateRatingLabel(rating: sender as! Double)
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
