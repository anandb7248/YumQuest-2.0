//
//  NearbyLocation.swift
//  YumQuest
//
//  Created by Anand Batjargal on 12/18/17.
//  Copyright © 2017 AnandBatjargal. All rights reserved.
//

import Foundation

// 
struct SearchForVenuesResponse : Decodable{
    let meta: Meta
    let response: Response
    
    struct Meta: Decodable{
        let code:Int
    }
    
    struct Response: Decodable {
        let venues: [SearchVenue]
        
        struct SearchVenue:Decodable {
            let id: String      // To be used to further obtain more information on the venue
            let name: String
            /*
            let location: Location
            
             struct Location: Decodable{
                 let address:String
                 let lat:Double
                 let lng:Double
                 let distance: Int
                 let city:String
                 let state:String
                 let country:String
             }
            */
        }
    }
}
