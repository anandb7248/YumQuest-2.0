//
//  DetailsOfVenueResponse.swift
//  YumQuest
//
//  Created by Anand Batjargal on 1/19/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import Foundation

class DetailFoodVenue {
    let id : String
    //let name : String
    //let contact
    //let location
    //let hours
    //let menu
    //let price
    //let rating
    //let ratingColor
    //let photos
    
    // Foursquare API venue response
    var getDetailsOfVenueResponse : GetDetailsOfVenueResponse?
    
    struct GetDetailsOfVenueResponse : Decodable {
        let meta: Meta
        let response: Response
        
        struct Meta: Decodable{
            let code:Int
        }
        
        struct Response: Decodable {
            let venue: VenueInfo
            
            struct VenueInfo : Decodable {
                let name : String
                let rating : Double?
                let ratingColor : String?
                let contact : ContactInfo
                
                struct ContactInfo : Decodable {
                    let phone : String?
                    let formattedPhone : String?
                }
            }
        }
        
    }
    
    init(venueId : String){
        id = venueId
        
        // Do an API call to fill the class's information
        guard let foursquareGetDetailsOfVenue = URL(string: "https://api.foursquare.com/v2/venues/\(id)?&client_id=RT1SBOGHXRKX5KCQIAKDKDIOMHIYEDSPHXPHJTYYRPDUHVCX&client_secret=QNAZYTA3UEMCGMZQBZTB5FUHSQHYXH0N4KAQ4J5TOF354DKL&v=20180121")
            else { print("Could not get detail venue request for id: " + venueId)
                return
        }
        
        URLSession.shared.dataTask(with: foursquareGetDetailsOfVenue) { (data, response, error) in
            // Check error
            if error != nil {
                print(error.debugDescription)
            }
            
            guard let data = data else { return }
            
            do {
                // Failing
                self.getDetailsOfVenueResponse = try JSONDecoder().decode(GetDetailsOfVenueResponse.self, from: data)
                // Failing
                
                guard let venueDetailResponse = self.getDetailsOfVenueResponse else { return }
                
                // Check Response Status
                if venueDetailResponse.meta.code != 200 {
                    print("JSON response failed in DetailFoodVenue")
                    return
                }
                
                // Test print
                print(venueDetailResponse.response.venue.name)
                print(venueDetailResponse.response.venue.contact.formattedPhone ?? "No formatted phone")
                print(String(describing: venueDetailResponse.response.venue.rating))
                
                DispatchQueue.main.async {
                    self.getDetailsOfVenueResponse = venueDetailResponse
                }
                
            } catch {
                print("Do block failed in Detail Food Venue for id: " + venueId)
            }
            
        }.resume()
    }
}
