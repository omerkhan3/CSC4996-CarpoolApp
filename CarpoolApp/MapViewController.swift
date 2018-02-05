//
//  MapViewController.swift
//  CarpoolApp
//
//  Created by Matt on 2/1/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GeoFire
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

        let locationManager = CLLocationManager()
    var centerMapped = false
    

    
    //linking mapview to this class
    @IBOutlet weak var mapview: MKMapView!
   
    //GeoFire
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    
    
    //Array With data from FireBase
   
 
    var lat = CLLocationDegrees()
    var long = CLLocationDegrees()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Map
        mapview.delegate = self
        mapview.userTrackingMode = MKUserTrackingMode.follow
        mapview.showsUserLocation = true

        //Geofire
        geoFireRef = Database.database().reference().child("userLocation")
        geoFire = GeoFire(firebaseRef: geoFireRef)

}
    //Brings up the user on the map after authorization
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
    }
    func locationAuthStatus () {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            mapview.showsUserLocation = true
            
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapview.showsUserLocation = true
        }
    }
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 7500, 7500)
        
        mapview.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !centerMapped {
                self.lat = userLocation.coordinate.latitude
                self.long = userLocation.coordinate.longitude
                centerMapOnLocation(location: loc)
                centerMapped = true
            }
//            geoFire.setLocation(CLLocation(latitude: self.userLatt, longitude: self.userLonn), forKey: "userLocation") { (error) in
//                if (error != nil) {
//                    print("An error occured: \(String(describing: error))")
//                } else {
//                    print("Saved location successfully!", self.userLatt, self.userLonn)
//                }
//            }
        }
    }
    //Annotation Override.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //User Annotation
        if (annotation is MKUserLocation)
        {
            return nil
        }
        
        let reuseId = "Image"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "Marker")
            
            let subtitleView = UILabel()
            subtitleView.font = subtitleView.font.withSize(12)
            subtitleView.numberOfLines = 2
            subtitleView.text = annotation.subtitle!
            annotationView?.detailCalloutAccessoryView = subtitleView
            
        }
        else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func getDataForMapAnnotation(Users: [[String:AnyObject]]){
        
        //Populates Map with annotations.
        
        for key in Users{
            
            let lat = key["LATITUDE"] as! CLLocationDegrees
            let long = key["LONGITUDE"] as! CLLocationDegrees
            let title = key["email"] as! String
            let subtitle = key["lastName"]
            let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
            _ = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(lat, long)
            annotation.title = title.capitalized
            annotation.subtitle = subtitle?.capitalized
            self.mapview.addAnnotation(annotation)
        }
    }

}
