//
//  GetNearbyVenues.swift
//  YumQuest
//
//  Created by Anand Batjargal on 2/11/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import Foundation
import CoreLocation

class GetNearbyVenuesHelper{
    var searchForVenuesResponse:SearchForVenuesResponse?
    var venues:[DetailFoodVenue]?
    
    init(latitude: CLLocationDegrees?, longitude: CLLocationDegrees?){
        guard let lat = latitude, let lon = longitude
            else {
                print("Latitude and Longitude are nil!")
                return
        }
        
        // Create URL based on users current location in order to get the nearby restaurants.
        // This categoryID corresponds to venues related to Food, as research from Foursquare documentation-> categoryId=4d4b7105d754a06374d81259
        guard let foursquareSearchNearbyFoodURL = URL(string: "https://api.foursquare.com/v2/venues/search?v=20161016&ll=\(lat)%2C%20\(lon)&intent=checkin&radius=1000&categoryId=4d4b7105d754a06374d81259&client_id=RT1SBOGHXRKX5KCQIAKDKDIOMHIYEDSPHXPHJTYYRPDUHVCX&client_secret=QNAZYTA3UEMCGMZQBZTB5FUHSQHYXH0N4KAQ4J5TOF354DKL") else
        { return }
        
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
                        
                        DispatchQueue.main.async{
                            self.searchForVenuesResponse = responseVenues
                            self.venues = tempVenues
                        }
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
}

extension Notification.Name {
    static let reload = Notification.Name("reload")
}
