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

class MapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var map: MKMapView!
    let manager = CLLocationManager()
    var currentLat:CLLocationDegrees?
    var currentLon:CLLocationDegrees?
    
    var nearbyVenues : GetNearbyVenuesHelper?
    var venueLocales = [VenueLocale]()
    //self.nearbyVenues = GetNearbyVenuesHelper(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.map.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        configureLocationManager()
        //getNearbyVenueLocations()
        DispatchQueue.main.async {
            self.nearbyVenues = GetNearbyVenuesHelper(latitude: self.currentLat, longitude: self.currentLon)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                let venueLocale = VenueLocale(venueRef: venueResp)
                
                venueLocales.append(venueLocale)
                map.addAnnotation(venueLocale)
                /*
                if let venue = venueResp.getDetailsOfVenueResponse?.response.venue{
                    let coordinates = CLLocationCoordinate2D(latitude: venue.location.lat!, longitude: venue.location.lng!)
                    //let venueLocale = VenueLocale(coord: coordinates, named: venue.name, detail: venue.categories[0].name!)
                    let venueLocale = VenueLocale(venue: venue)
                    
                    venueLocales.append(venueLocale)
                }
                */
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        /*
         if annotation is School {
         let annotationView = MKPinAnnotationView()
         annotationView.pinTintColor = .red
         annotationView.annotation = annotation
         annotationView.canShowCallout = true
         annotationView.animatesDrop = true
         
         return annotationView
         }
         */
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "") {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:"")
            annotationView.isEnabled = true
            annotationView.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = btn
            return annotationView
        }
        
        //return nil
    }
    
    // Function lets the delegate know that the location has been updated.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            currentLat = location.coordinate.latitude
            currentLon = location.coordinate.longitude
            
            /*
            // Not sure if this is the best place to get the nearby venues
            DispatchQueue.main.async {
                self.nearbyVenues = GetNearbyVenuesHelper(latitude: self.currentLat, longitude: self.currentLon)
            }
            */
            
            // Zoom in the map on the location
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.025, 0.025)
            let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
            
            map.setRegion(region, animated: true)
            
            if let venueResp = self.nearbyVenues?.venues{
                for venue in venueResp{
                    
                    DispatchQueue.main.async {
                        let venueLocale = VenueLocale(venueRef: venue)
                        self.map.addAnnotation(venueLocale)
                    }
                }
            }
            
            //map.addAnnotations(venueLocales)
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        performSegue(withIdentifier: "showRestaurantDetailsFromMap", sender: view.annotation)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetailsFromMap"{
            let destVC = segue.destination as! RestaurantDetailsVC
            let detailVenue = sender as! VenueLocale
            
            destVC.detailFoodVenue = detailVenue.venueRef
        }
    }

}
