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
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth
import Braintree
import BraintreeDropIn

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
  let locationManager = CLLocationManager()
    @IBOutlet weak var paymentButton: UIButton!
    
    let tokenizationKey =  "sandbox_vtqbvdrz_kjjqnn2gj7vbds9g" // this is the tokenization key needed to authenticate with Braintree sandbox.  Since this is just a sandbox account, we have hard-coded the key in, but for production this key would need to be hosted elsewhere.
    
    var ref: DatabaseReference! // create database reference
    var centerMapped = false
    

    
    //linking mapview to this class
    @IBOutlet weak var mapview: MKMapView!
    
   
    //GeoFire
//    var geoFire: GeoFire!
//    var geoFireRef: DatabaseReference!
    
    
    //Array With data from FireBase
   
 
    var lat = CLLocationDegrees()
    var long = CLLocationDegrees()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user1 = "DLB4aElaJ6WNr7V9593Ey1jPS023"
        
        // Set up Map
        mapview.delegate = self
        mapview.userTrackingMode = MKUserTrackingMode.follow
        mapview.showsUserLocation = true

        //Geofire
//        geoFireRef = Database.database().reference().child("userLocation")
//        geoFire = GeoFire(firebaseRef: geoFireRef)
        
//        ref = Database.database().reference().child("Users") // Create reference to child node
//        ref.child(user1).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let value = snapshot.value as? NSDictionary
//            let userLong = value?["long"] as? CLLocationDegrees
//            let userLat = value?["lat"] as? CLLocationDegrees
//            let firstName = value?["firstName"] as? String ?? ""
//            let lastName = value?["lastName"] as? String ?? ""
//            print("User ID: ")
//            print(user1)
//            print("Saved Longitude: ")
//            print(userLong!)
//            print("Saved Latitude: ")
//            print(userLat!)
//            print("lastName: ")
//            print(lastName)
        
//            let additionLocation = otherlocations(title: lastName!, )
//            let center = CLLocationCoordinate2D(latitude: userLat!, longitude: userLong!)
//            _ = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
            
            
            
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = CLLocationCoordinate2DMake(userLat, userLong)
//            //annotation.title = lastName.capitalized
//            // annotation.subtitle = subtitle?.capitalized
//            self.mapview.addAnnotation(annotation)
//        }) { (error) in
//            print(error.localizedDescription)
            //        }
//        })

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
        //use later if we want to have annotations over the person
        let reuseId = ""
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
    
    @IBAction func paymentAction(_ sender: UIButton) {
        showDropIn(clientTokenOrTokenizationKey: self.tokenizationKey) // Drop-in is initalized on-click.
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        // The tokenization key is what we use to authenticate client-side to Braintree, and allows us access to drop-in.
        let dropIn = BTDropInController(authorization: self.tokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {  // if there are errors when calling the Braintree Dropin.
                print("Error.")
            } else if (result?.isCancelled == true) { // if selects the cancel option of UI.
                print("Cancelled.")
                
            } else if let result = result {
                let selectedPaymentMethod = result.paymentMethod?.nonce // the nonce contains unique identifiers about the transaction that are needed by the server to process the transaction.
                
                self.postNonceToServer(paymentMethodNonce: selectedPaymentMethod!) // this is the call to send the nonce to the server.
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    
    
    func postNonceToServer(paymentMethodNonce: String) { // method to send unique payment "nonce" to the server for transaction processing.
        let paymentURL = URL(string: "http://localhost:3000/checkout")! // the URL endpoint of our local node server.  We will need to switch this when we are able to host somewhere else.
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(paymentMethodNonce)".data(using: String.Encoding.utf8) // "payment_method_nonce" is the field that the server will be looking for to receive the nonce.
        request.httpMethod = "POST" // POST method.
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print ("An error has occured.")
            }
            else{
                print ("Success!")
            }
            
            }.resume()
    }
    
    
    

}
