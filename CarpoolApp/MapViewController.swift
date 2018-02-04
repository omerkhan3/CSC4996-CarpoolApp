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


class MapViewController: UIViewController, CLLocationManagerDelegate {

        let locationManager = CLLocationManager()
    
    
   // let geofireRef = Firebase(url: "https://<your-firebase>.firebaseio.com/")
   // let geoFire = GeoFire(firebaseRef: geofireRef)
    
    //linking mapview to this class
    @IBOutlet weak var mapview: MKMapView!
   
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        geoFire.setLocation(CLLocation(latitude: 37.7853889, longitude: -122.4056973), forKey: "EyzXZsmtEDUdBxd3YY0jklx58Zu2")
//
//        geoFire.setLocation(CLLocation(latitude: 37.7853889, longitude: -122.4056973), forKey: "EyzXZsmtEDUdBxd3YY0jklx58Zu2") { (error) in
//            if (error != nil) {
//                print("An error occured: \(error)")
//            } else {
//                print("Saved location successfully!")
//            }
//        }
        
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        
        // For use when the app is open
        locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
        }
        //starting sample location that works in emulator california location
        let samplelocation = otherlocations(title: "sample locations",
        //name of description
        locationName: "sample description",
        //prewritten plot
        coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.431297))
       //adding blip on map
        mapview.addAnnotation(samplelocation)
        
        
        
        // Do any additional setup after loading the view.
            
}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // testing to see that location services work so it will print out the location to the console
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.2, 0.2)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapview.setRegion(region, animated: true)
            print(location.coordinate)
        }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "You need to allow locations services for this app to function correctly",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
  

}

