//
//  MenuDetailsVCViewController.swift
//  YumQuest
//
//  Created by Anand Batjargal on 2/7/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//
import UIKit
import Firebase

class MenuDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CollapsibleTableViewHeaderDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueRatingLabel: UILabel!
    
    //var sectionToItemsDict = [String : [MenuItem]]()
    //var menuSections = [String]()
    var restaurantDetails : DetailFoodVenue?
    
    var sections = [MenuTableSection]()
    
    var itemRatingsReviewsRef: DatabaseReference  = Database.database().reference().child("ItemRatingReviews")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To reload the table in a different view controller
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 25
        
        if let restaurant = restaurantDetails {
            venueNameLabel.text = restaurant.getDetailsOfVenueResponse?.response.venue.name
            let rating = getFormattedRating(ratingDouble: restaurant.getDetailsOfVenueResponse?.response.venue.rating)
            venueRatingLabel.text = rating
            venueRatingLabel.backgroundColor = hexStringToUIColor(hex: restaurant.getDetailsOfVenueResponse?.response.venue.ratingColor)
        }
        
        for menuCategory in (restaurantDetails?.menu?.response.menu?.menus?.items)!{
            //print("------------Category------------")
            //print(menuCategory.name  ?? "Empty Category Name")
            for menuSection in (menuCategory.entries?.items)!{
                //print("------------Section------------")
                //print(menuSection.name  ?? "Empty Section Name")
                sections.append(MenuTableSection(sectionName: menuSection.name!, menuItems: menuSection.entries.items!))

                /*
                for menuItem in menuSection.entries.items!{
                    print(menuItem.name ?? "Empty Name")
                    print(menuItem.price ?? "Empty Price")
                    print(menuItem.description ?? "Empty Description")
                }
                */
            }
        }
    }
    
    @objc func loadList(){
        //load data here
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].collapsed ? 0 : sections[section].menuItems.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell") as! MenuTVC
        
        cell.itemNameLabel.text = sections[indexPath.section].menuItems[indexPath.row].name
        cell.priceLabel.text = sections[indexPath.section].menuItems[indexPath.row].price
        cell.descriptionLabel.text = sections[indexPath.section].menuItems[indexPath.row].description
        
        if let itemID = sections[indexPath.section].menuItems[indexPath.row].entryId{
            itemRatingsReviewsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(itemID){
                    //let avgRating = snapshot
                    //cell.ratingLabel.text = "NA"
                    self.itemRatingsReviewsRef.child(itemID).child("averageRating").observeSingleEvent(of: .value, with: { snapshot in
                        let rating = snapshot.value as! Double
                        cell.ratingLabel.text = String(format:"%.1f",rating)
                    })
                }
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        
        header.titleLabel.text = sections[section].sectionName
        header.arrowLabel.text = ">"
        header.setCollapsed(sections[section].collapsed)
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int) {
        let collapsed = !sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        // Reload the whole section
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showItemDetails"){
            let destVC = segue.destination as! ItemDetailsVC
            
            // Chosen should be a MenuItem
            let chosenItem = sections[(tableView.indexPathForSelectedRow?.section)!].menuItems[(tableView.indexPathForSelectedRow?.row)!]
            
            destVC.menuItem = chosenItem
            
            if let restaurant = restaurantDetails {
                destVC.venueName = restaurant.getDetailsOfVenueResponse?.response.venue.name
            }
        }
    }
}
