//
//  VenueLocale.swift
//  YumQuest
//
//  Created by Anand Batjargal on 2/11/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import Foundation
import MapKit

class VenueLocale : NSObject, MKAnnotation {
    var venueRef : DetailFoodVenue
    
    // Conform to MKAnnotation
    var coordinate: CLLocationCoordinate2D{
        if let latitude = venueRef.getDetailsOfVenueResponse?.response.venue.location.lat{
            if let longitude = venueRef.getDetailsOfVenueResponse?.response.venue.location.lng{
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
     }
        return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
     }
    
    var title: String?{
        if let name = venueRef.getDetailsOfVenueResponse?.response.venue.name{
            return name
        }else{
            return "N/A"
        }
    }
    
    var subtitle: String?{
        if let category = venueRef.getDetailsOfVenueResponse?.response.venue.categories[0].name{
            return category
        }else{
            return "N/A"
        }
    }
    // Conform to MKAnnotation
    
    //coord: CLLocationCoordinate2D, named: String, detail: String,
    init(venueRef : DetailFoodVenue) {
        self.venueRef = venueRef
        //super.init()
    }
}
