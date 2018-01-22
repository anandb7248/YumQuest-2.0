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
    var searchForVenuesResponse:SearchForVenuesResponse?
    var venues:[DetailFoodVenue]?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getUsersCurrentCoordinates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = searchForVenuesResponse?.response.venues.count else {return 0}
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueInfoTVC", for: indexPath) as! VenueInfoTVC
        
        //let restaurant = searchForVenuesResponse?.response.venues[indexPath.row]
        let restaurant = venues![indexPath.row].getDetailsOfVenueResponse?.response.venue
        //listOfNearbyRestaurants[indexPath.row]
        
        cell.nameLabel.text = restaurant?.name
        cell.ratingLabel.text = getFormattedRating(ratingDouble: restaurant?.rating)
        cell.ratingLabel.backgroundColor = hexStringToUIColor(hex: restaurant?.ratingColor)
        
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
        
        //cString.characters.count
        
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
            getNearbyVenues(latitude: currentLat, longitude: currentLon)
            print(currentLat!)
            print(currentLon!)
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
        // WORKS
        //print(foursquareSearchNearbyFoodURL!)
        
        URLSession.shared.dataTask(with: foursquareSearchNearbyFoodURL) { (data, response, error) in
            // Check error
            if error != nil {
                print(error.debugDescription)
            }

            guard let data = data else { return }
            do {
                self.searchForVenuesResponse = try JSONDecoder().decode(SearchForVenuesResponse.self, from: data)
                guard let responseVenues = self.searchForVenuesResponse else { return }
                // Check Response Status
                if responseVenues.meta.code != 200 {
                    print("Json response failed")
                    return
                }
                
                var tempVenues:[DetailFoodVenue] = []
                
                // TEST print
                for venue in (self.searchForVenuesResponse?.response.venues)! {
                    //print(venue.name)
                    // Use the venue id's to create new DetailVenue objects
                    //print(venue.id)
                    tempVenues.append(DetailFoodVenue(venueId: venue.id))
                }
                
                DispatchQueue.main.async {
                    self.searchForVenuesResponse = responseVenues
                    self.venues = tempVenues
                    self.tableView.reloadData()
                }
                
            }catch {
                print("Did not work!")
            }

        }.resume()
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