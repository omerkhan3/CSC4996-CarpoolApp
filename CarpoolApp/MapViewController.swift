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
//import SwiftyJSON
import GeoFire


class MapViewController: UIViewController, CLLocationManagerDelegate {

        let locationManager = CLLocationManager()
    
    //linking mapview to this class
    @IBOutlet weak var mapview: MKMapView!
    
    //var user = [otherlocations]()
    
//    func fetchData()
//    {
//        let fileName = Bundle.main.path(forResource: "jsonlist", ofType: "json")
//        let filePath = URL(fileURLWithPath: fileName!)
//        var data: Data?
//        do {
//            data = try Data(contentsOf: filePath, options: Data.ReadingOptions(rawValue: 0))
//        } catch let error {
//            data = nil
//            print("Report error \(error.localizedDescription)")
//        }
//
//        if let jsonData = data {
//
//                let json:JSON =  JSON(data: jsonData)
//
//            if let UsersJSONs = json["Users"]["User"].array {
//                for UsersJSON in UsersJSONs {
//                    if let user = otherlocations.from(json: UsersJSON) {
//                        self.user.append(user)
//                    }
//                }
//            }
//        }
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            let span = MKCoordinateSpanMake(0.05, 0.05)
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

