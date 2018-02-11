//
//  MenuDetailsVCViewController.swift
//  YumQuest
//
//  Created by Anand Batjargal on 2/7/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//
import UIKit

class MenuDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CollapsibleTableViewHeaderDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueRatingLabel: UILabel!
    
    //var sectionToItemsDict = [String : [MenuItem]]()
    //var menuSections = [String]()
    var restaurantDetails : DetailFoodVenue?
    
    var sections = [MenuTableSection]()
    
    // Sorted Array of Sections
    // Sorted Array of Menu Items
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            print("------------Category------------")
            print(menuCategory.name  ?? "Empty Category Name")
            for menuSection in (menuCategory.entries?.items)!{
                print("------------Section------------")
                print(menuSection.name  ?? "Empty Section Name")
                sections.append(MenuTableSection(sectionName: menuSection.name!, menuItems: menuSection.entries.items!))

                for menuItem in menuSection.entries.items!{
                    print(menuItem.name ?? "Empty Name")
                    print(menuItem.price ?? "Empty Price")
                    print(menuItem.description ?? "Empty Description")
                }
            }
        }
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
