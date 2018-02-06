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
    
   // var centerMapped = false
    

    
    //linking mapview to this class
    @IBOutlet weak var mapview: MKMapView!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user1 = "DLB4aElaJ6WNr7V9593Ey1jPS023"
        
        let center = CLLocation(latitude: 37.77,  longitude: -122.41)  // Test Query on user locations to see who is found within a 100 mile radius.
        let circleQuery = geoFire.query(at: center, withRadius: 100)
        _ = circleQuery.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
            print("Found User: ", key!)  // print UID of users found.
        })
        let result = circleQuery.observeReady({})
        
         // print("Done Querying. ")
        
        let samplelocation = otherlocations(title: "sample location",
                    locationName: "sample description",
            coordinate: CLLocationCoordinate2D(latitude: 42.3410, longitude: -83.0552))
                mapview.addAnnotation(samplelocation)
     
        
//        func getDataForMapAnnotation(Users: [[String:AnyObject]]){
//
//            //Populates Map with annotations.
//
//            for key in Users{
//
//                let lat = key["LATITUDE"] as! CLLocationDegrees
//                let long = key["LONGITUDE"] as! CLLocationDegrees
//                let title = key["email"] as! String
//                let subtitle = key["lastName"]
//                let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
//                _ = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
//
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = CLLocationCoordinate2DMake(lat, long)
//                annotation.title = "testtitle"
//                //annotation.subtitle = subtitle?.capitalized
//                self.mapview.addAnnotation(annotation)
//            }
//        }
        
        
        // Set up Map
        mapview.delegate = self
        mapview.userTrackingMode = MKUserTrackingMode.follow
        mapview.showsUserLocation = true

        //displayAnnotations()        //Geofire
//        geoFireRef = Database.database().reference().child("userLocation")
//        geoFire = GeoFire(firebaseRef: geoFireRef)
        
     //   ref = Database.database().reference().child("Users") // Create reference to child node
     //   ref.child(user1).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
     //       let value = snapshot.value as? NSDictionary
       //     let userLat = (snapshot.value as AnyObject!)!["lat"] as! String!
         //   let userLong = (snapshot.value as AnyObject!)!["long"] as! String!
          
     //       let firstName = value?["firstName"] as? String ?? ""
//           let lastName = value?["lastName"] as? String ?? ""
//            print("User ID: ")
//            print(user1)
         // print("Saved Longitude: ")
          //  print(userLong!)
         //  print("Saved Latitude: ")
         //   print(userLat!)
//            print("lastName: ")
//            print(lastName)
        
//            let additionLocation = otherlocations(title: lastName!, )
           // let center = CLLocationCoordinate2D(latitude: userLat, longitude: userLong)
         //   _ = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            
          //  let annotation = MKPointAnnotation()
            
         //   annotation.coordinate = CLLocationCoordinate2D(latitude: (Double(userLat!))!, longitude: (Double(userLong!))!)
          //  annotation.title = "test"
         //   annotation.subtitle = "test"
           // self.mapview.addAnnotation(annotation)
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = CLLocationCoordinate2DMake(userLat, userLong)
//            //annotation.title = lastName.capitalized
//            annotation.subtitle = firstName.capitalized
//            self.mapview.addAnnotation(annotation)
//        }) { (error) in
//            print(error.localizedDescription)
            //        }
    //   })

}
    func displayAnnotations() {

        let ref = Database.database().reference()
        ref.child("user1").observe(.childAdded, with: { (snapshot) in

           
            let latitude = (snapshot.value as AnyObject!)!["lat"] as! String!
            let longitude = (snapshot.value as AnyObject!)!["long"] as! String!


            let annotation = MKPointAnnotation()

            annotation.coordinate = CLLocationCoordinate2D(latitude: (Double(latitude!))!, longitude: (Double(longitude!))!)
            annotation.title = "date"
            annotation.subtitle = "time"
            self.mapview.addAnnotation(annotation)
    
        })}


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
    
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        if let loc = userLocation.location {
//            if !centerMapped {
//                self.lat = userLocation.coordinate.latitude
//                self.long = userLocation.coordinate.longitude
//                centerMapOnLocation(location: loc)
//                centerMapped = true
//            }
    
            
            //testing to make sure i can write to firebase through geo coordinates
            
//            geoFire.setLocation(CLLocation(latitude: self.userLatt, longitude: self.userLonn), forKey: "userLocation") { (error) in
//                if (error != nil) {
//                    print("An error occured: \(String(describing: error))")
//                } else {
//                    print("Saved location successfully!", self.userLatt, self.userLonn)
//                }
//            }
    
    
   
    
  
    
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
