//
//  MapVC.swift
//  YumQuest
//
//  Created by Anand Batjargal on 2/11/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    let manager = CLLocationManager()
    var currentLat:CLLocationDegrees?
    var currentLon:CLLocationDegrees?
    
    var nearbyVenues : GetNearbyVenuesHelper?
    var venueLocales = [VenueLocale]()
    //self.nearbyVenues = GetNearbyVenuesHelper(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureLocationManager(){
        CLLocationManager.locationServicesEnabled()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    // Helper function
    // Will get the api response from nearbyVenues and fill the venueLocales.
    func getNearbyVenueLocations(){
        if let venuesResp = nearbyVenues?.venues{
            for venueResp in venuesResp{
                if let venue = venueResp.getDetailsOfVenueResponse?.response.venue{
                    let coordinates = CLLocationCoordinate2D(latitude: venue.location.lat!, longitude: venue.location.lng!)
                    let venueLocale = VenueLocale(coord: coordinates, named: venue.name, detail: venue.categories[0].name!)
                    
                    venueLocales.append(venueLocale)
                }
            }
        }
    }
    
    // Function lets the delegate know that the location has been updated.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            currentLat = location.coordinate.latitude
            currentLon = location.coordinate.longitude
            print(currentLat!)
            print(currentLon!)
            
            self.nearbyVenues = GetNearbyVenuesHelper(latitude: self.currentLat, longitude: self.currentLon)
            
            // Zoom in the map on the location
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
            
            map.setRegion(region, animated: true)
            map.addAnnotations(venueLocales)
            self.map.showsUserLocation = true
        }
        
        /*
        for venue in (nearbyVenues?.venues)!{
            if let lat = venue.getDetailsOfVenueResponse?.response.venue.location.lat{
                if let lon = venue.getDetailsOfVenueResponse?.response.venue.location.lng{
                    let venueCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    let venueLocation = VenueLocale(coord: venueCoordinate, named:(venue.getDetailsOfVenueResponse?.response.venue.name)!, detail:(venue.getDetailsOfVenueResponse?.response.venue.categories[0].name)!)
                    venueLocales.append(venueLocation)
                }
            }
            //venue.getDetailsOfVenueResponse?.response.venue.location.lat
            //venue.getDetailsOfVenueResponse?.response.venue.location.lng
            // name
            //venue.getDetailsOfVenueResponse?.response.venue.name
            // detail (category)
            //venue.getDetailsOfVenueResponse?.response.venue.categories[0].name
        }
         */
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
