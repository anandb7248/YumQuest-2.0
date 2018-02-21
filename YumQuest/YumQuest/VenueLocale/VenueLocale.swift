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
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coord: CLLocationCoordinate2D, named: String, detail: String) {
        coordinate = coord
        title = named
        subtitle = detail
        
        super.init()
    }
}
