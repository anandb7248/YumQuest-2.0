//
//  Restaurants.swift
//  YumQuest
//
//  Created by Anand Batjargal on 12/17/17.
//  Copyright © 2017 AnandBatjargal. All rights reserved.
//

import UIKit
import CoreLocation

class NearbyLocationsVC: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    // Location
    let locationManager = CLLocationManager()
    var currentLat:CLLocationDegrees?
    var currentLon:CLLocationDegrees?
    
    // Foursquare API venue response
    var nearbyVenues:GetNearbyVenuesHelper?
    //var searchForVenuesResponse:SearchForVenuesResponse?
    //var venues:[DetailFoodVenue]?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // For notification to use to reload the table view data when the api requests have been completed
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reload, object: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        getUsersCurrentCoordinates()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadTableData(_ notification: Notification) {
        tableView.reloadData()
    }
    
    // HIDE NAVIGATION BAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    // HIDE NAVIGATION BAR
    
    // TOGGLE VENUES WITH MENUS
    
    // TOGGLE VENUES WITH MENUS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ven = nearbyVenues?.venues {
            return ven.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueInfoTVC", for: indexPath) as! VenueInfoTVC
        
        // check if venues has values first.
        if let venues = nearbyVenues?.venues {
            if let restaurant = venues[indexPath.row].getDetailsOfVenueResponse?.response.venue {
                cell.nameLabel.text = restaurant.name
                cell.ratingLabel.text = getFormattedRating(ratingDouble: restaurant.rating)
                cell.ratingLabel.backgroundColor = hexStringToUIColor(hex: restaurant.ratingColor)
                cell.categoryLabel.text = restaurant.categories[0].name
                cell.pricetierLabel.text = restaurant.price.currency
                if let address = restaurant.location.address {
                    if let city = restaurant.location.city {
                        if let state = restaurant.location.state {
                            cell.addressLabel.text = address + ", " + city + ", " + state
                        }else{
                            cell.addressLabel.text = address + ", " + city
                        }
                    }else{
                        cell.addressLabel.text = address
                    }
                }else{
                    cell.addressLabel.text = "Address Unknown"
                }
                
                if let hasMenu = venues[indexPath.row].hasMenu {
                    if hasMenu {
                        cell.hasMenuIndicator.isHidden = false
                    }else{
                        cell.hasMenuIndicator.isHidden = true
                    }
                }else{
                    cell.hasMenuIndicator.isHidden = true
                }
            }
        }
        
        return cell
    }
    //------------------
    // START OF UTILITY FUNCTIONS
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
    
    // END OF UTILITY FUNCTIONS
    // -----------------
    
    // START Location functions
    func getUsersCurrentCoordinates(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        
        // One-time call to obtain the users current location. This calls the method locationManager(didUpdateLocations)
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            currentLat = location.coordinate.latitude
            currentLon = location.coordinate.longitude
            //getNearbyVenues(latitude: currentLat, longitude: currentLon)
            //print(currentLat!)
            //print(currentLon!)
            self.nearbyVenues = GetNearbyVenuesHelper(latitude: self.currentLat, longitude: self.currentLon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied){
            showLocationDisabledPopUp()
        }
    }
    
    func showLocationDisabledPopUp(){
        let alertController = UIAlertController(title: "Location Access Disabled", message: "In order to display nearby venues YumQuest needs access to your current location",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel,
                                         handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings",
                                       style: .default) { (action) in
                                        if let url = URL(string: UIApplicationOpenSettingsURLString){
                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                        }
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true,completion: nil)
    }
    // END Location functions
    
    /*
    func getNearbyVenues(latitude: CLLocationDegrees?, longitude: CLLocationDegrees?){
        guard let lat = latitude, let lon = longitude
            else {
                print("Latitude and Longitude are nil!")
                return
            }
        
        // Create URL based on users current location in order to get the nearby restaurants.
        // This categoryID corresponds to venues related to Food, as research from Foursquare documentation-> categoryId=4d4b7105d754a06374d81259
        guard let foursquareSearchNearbyFoodURL = URL(string: "https://api.foursquare.com/v2/venues/search?v=20161016&ll=\(lat)%2C%20\(lon)&intent=checkin&radius=1000&categoryId=4d4b7105d754a06374d81259&client_id=RT1SBOGHXRKX5KCQIAKDKDIOMHIYEDSPHXPHJTYYRPDUHVCX&client_secret=QNAZYTA3UEMCGMZQBZTB5FUHSQHYXH0N4KAQ4J5TOF354DKL") else
            { return }
        // https://api.foursquare.com/v2/venues/search?v=20161016&ll=37.7739%2C%20-122.431&intent=checkin&radius=1000&categoryId=4d4b7105d754a06374d81259&client_id=RT1SBOGHXRKX5KCQIAKDKDIOMHIYEDSPHXPHJTYYRPDUHVCX&client_secret=QNAZYTA3UEMCGMZQBZTB5FUHSQHYXH0N4KAQ4J5TOF354DKL
        
        URLSession.shared.dataTask(with: foursquareSearchNearbyFoodURL) { (data, response, error) in
            // Check error
            if error != nil {
                print(error.debugDescription)
            }
            
            if let data = data {
                do {
                    self.searchForVenuesResponse = try JSONDecoder().decode(SearchForVenuesResponse.self, from: data)
                    if let responseVenues = self.searchForVenuesResponse {
                        // Check Response Status
                        if responseVenues.meta.code != 200 {
                            print("Json response failed")
                            return
                        }
                        var tempVenues:[DetailFoodVenue] = []
                        for venue in responseVenues.response.venues {
                            //print(venue.name)
                            // Use the venue id's to create new DetailVenue objects
                            //print(venue.id)
                            //tempVenues.append(DetailFoodVenue(venueId: venue.id))
                            tempVenues.append(DetailFoodVenue(venueId: venue.id))
                            //self.tableView.reloadData()
                        }
                        
                        DispatchQueue.global().async{
                            self.searchForVenuesResponse = responseVenues
                            self.venues = tempVenues
                            //self.tableView.reloadData()
                            self.tableView.reloadData()
                        }
                        /*
                        //(self.searchForVenuesResponse?.response.venues)!
                        for venue in responseVenues.response.venues {
                            //print(venue.name)
                            // Use the venue id's to create new DetailVenue objects
                            //print(venue.id)
                            tempVenues.append(DetailFoodVenue(venueId: venue.id))
                        }
                        */
                    }
                }
                catch {
                    print("Error!")
                }
            }
            else {
                return
            }
        }.resume()
    }
    */
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showRestaurantDetails"){
            let destVC = segue.destination as! RestaurantDetailsVC
            //destVC.detailFoodVenue = venues?[(tableView.indexPathForSelectedRow?.row)!]
            destVC.detailFoodVenue = nearbyVenues?.venues![(tableView.indexPathForSelectedRow?.row)!]
        }
    }
}
