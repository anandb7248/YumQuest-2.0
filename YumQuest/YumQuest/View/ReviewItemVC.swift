//
//  ReviewItemVC.swift
//  YumQuest
//
//  Created by Anand Batjargal on 3/10/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import UIKit
import Firebase

class ReviewItemVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var name : String?
    var item : MenuItem?
    // Firebase reference
    var itemRef : DatabaseReference = Database.database().reference().child("MenuItems")

    @IBOutlet weak var ratingPicker: UIPickerView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    
    let ratingOptions = ["1", "2", "3", "4", "5", "6","7","8","9","10"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = name{
            venueNameLabel.text = name
        }
        if let item = item{
            itemNameLabel.text = item.name
        }
        
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
    
    @IBAction func submitReview(_ sender: Any) {
        var usersRating = Double(ratingPicker.selectedRow(inComponent: 0)) + 1.0
        
        itemRef.child((item?.entryId)!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! [String : AnyObject]
            
            let curRating = value["Rating"] as! Double
            let curNumberOfRatings = value["NumberOfRatings"] as! Int
            let curTotalRatings = value["TotalRatings"] as! Int
                
            print(curRating)
            print(curNumberOfRatings)
            print(curTotalRatings)
            //self.menuItemsRef.child(id).setValue(["NumberOfRatings" : 0, "TotalRatings": 0, "Rating":0.0])
            if curRating == 0.0{
                self.itemRef.child((self.item?.entryId)!).setValue(["NumberOfRatings" : 1, "TotalRatings": Int(usersRating), "Rating":usersRating])
            }else{
                let newNumberOfRatings = curNumberOfRatings + 1
                let newTotalRatings = Double(curTotalRatings) + usersRating
                let newRating = newTotalRatings / Double(newNumberOfRatings)
                self.itemRef.child((self.item?.entryId)!).setValue(["NumberOfRatings" : newNumberOfRatings, "TotalRatings": newTotalRatings, "Rating": newRating])
            }
            
            self.performSegue(withIdentifier: "unwindToItemDetails", sender: usersRating)
            // If a value exists that corresponds to the entryID key...
            /*
            if let previousRating = snapshot.value as? Double?{
                
                if previousRating == 0.0 {
                    let editRef = self.itemRef.child((self.item?.entryId)!)
                    
                    //editRef.updateChildValues([(self.item?.entryId)!:usersRating])
                    self.performSegue(withIdentifier: "unwindToItemDetails", sender: usersRating)
                }else{
                    usersRating = (previousRating! + usersRating)/2
                    //self.itemRef.updateChildValues([(self.item?.entryId)!: usersRating])
                    let editRef = self.itemRef
                    editRef.updateChildValues([(self.item?.entryId)!:usersRating])
                    self.performSegue(withIdentifier: "unwindToItemDetails", sender: usersRating)
                }
            }
            */
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
