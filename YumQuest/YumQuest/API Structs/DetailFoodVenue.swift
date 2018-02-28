//
//  DetailsOfVenueResponse.swift
//  YumQuest
//
//  Created by Anand Batjargal on 1/19/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import Foundation
import Firebase

class DetailFoodVenue {
    let id : String
    var hasMenu:Bool?
    var menu : Menu?
    // Firebase reference
    var menuItemsRef: DatabaseReference  = Database.database().reference().child("MenuItems")
    
    // Foursquare API venue response
    var getDetailsOfVenueResponse : GetDetailsOfVenueResponse?
    
    // Part of API Request
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
                let ratingSignals : Int?
                let contact : ContactInfo
                let location : LocationInfo
                let price : PriceInfo
                let hasMenu: Bool?
                let categories : [CategoryInfo]

                struct ContactInfo : Decodable {
                    let phone : String?
                    let formattedPhone : String?
                }
                
                struct LocationInfo : Decodable {
                    let address : String?
                    let city: String?
                    let state: String?
                    let lat: Double?
                    let lng: Double?
                }
                
                struct PriceInfo : Decodable {
                    let currency : String?
                }
                
                struct CategoryInfo : Decodable {
                    let name : String?
                }
            }
        }
    }
    
    // Part of API Request
    init(venueId : String){
        id = venueId
        // Do an API call to fill the class's information
        if let foursquareGetDetailsOfVenue = URL(string: "https://api.foursquare.com/v2/venues/\(id)?&client_id=RT1SBOGHXRKX5KCQIAKDKDIOMHIYEDSPHXPHJTYYRPDUHVCX&client_secret=QNAZYTA3UEMCGMZQBZTB5FUHSQHYXH0N4KAQ4J5TOF354DKL&v=20180121"){
            
            URLSession.shared.dataTask(with: foursquareGetDetailsOfVenue) { (data, response, error) in
                // Check error
                if error != nil {
                    print(error.debugDescription)
                }
                
                if let data = data {
                    do {
                        self.getDetailsOfVenueResponse = try JSONDecoder().decode(GetDetailsOfVenueResponse.self, from: data)
                        
                        if let venueDetailResponse = self.getDetailsOfVenueResponse {
                            // Check Response Status
                            if venueDetailResponse.meta.code != 200 {
                                print("JSON response failed in DetailFoodVenue")
                                return
                            }
                            // Check if the venue has a menu using a seperate request
                            if let hasMenu = venueDetailResponse.response.venue.hasMenu{
                                if hasMenu {
                                    self.getMenu(venueId: self.id)
                                }
                            }
                            
                            // In here I can use the lat and lon information to write to GeoFire
                            
                            
                            DispatchQueue.main.sync {
                                self.getDetailsOfVenueResponse = venueDetailResponse
                                NotificationCenter.default.post(name: .reload, object: nil)
                            }
                        }
                        
                    } catch {
                        print("Do block failed in Detail Food Venue for id: " + venueId)
                        print("Request: \(foursquareGetDetailsOfVenue)")
                    }
                }
                }.resume()
        }else{
            print("Error: Using id - \(id) to obtain GetDetailsOfVenue Request has failed")
        }
    }

    private func getMenu(venueId : String) {
        if let foursquareGetMenuURL = URL(string: "https://api.foursquare.com/v2/venues/\(venueId)/menu?&client_id=RT1SBOGHXRKX5KCQIAKDKDIOMHIYEDSPHXPHJTYYRPDUHVCX&client_secret=QNAZYTA3UEMCGMZQBZTB5FUHSQHYXH0N4KAQ4J5TOF354DKL&v=20180121"){
            
            URLSession.shared.dataTask(with: foursquareGetMenuURL) { (data, response, error) in
                // Check error
                if error != nil {
                    print(error.debugDescription)
                }
                
                if let data = data {
                    do {
                        self.menu = try JSONDecoder().decode(Menu.self, from: data)
                        
                        // Firebase
                        //self.menuItemsRef = try
                        
                        if let menuResponse = self.menu {
                            print(self.getDetailsOfVenueResponse?.response.venue.name)
                            print(foursquareGetMenuURL)
                            
                            // For testing purposes
                            //ITERATE THROUGH EVERY ITEM
                            if let itemArrOne = menuResponse.response.menu?.menus?.items{
                                for item in itemArrOne {
                                    if let itemArrTwo = item.entries?.items{
                                        for item in itemArrTwo{
                                            if let itemArrThree = item.entries.items{
                                                for item in itemArrThree {
                                                    if let id = item.entryId{
                                                        // Write the id to Firebase
                                                        self.menuItemsRef.child(id).setValue(0.0)
                                                    }
                                                    if let name = item.name{
                                                        print(name)
                                                    }
                                                    if let price = item.price{
                                                        print(price)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if let count = menuResponse.response.menu?.menus?.count{
                                if count > 0 {
                                    self.hasMenu = true
                                }else{
                                    self.hasMenu = false
                                }
                            }
                            
                            DispatchQueue.main.sync {
                                self.menu = menuResponse
                                NotificationCenter.default.post(name: .reload, object: nil)
                            }
                            
                        }
                        
                    } catch {
                        print("Do block failed in getMenu() for id: " + venueId)
                    }
                }
                }.resume()
        }
    }
}
