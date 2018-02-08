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
    
    // Class variables
    let locationManager = CLLocationManager()
    var ref: DatabaseReference! // Creates database reference
    var currentPlacemark:CLPlacemark?
    let tokenizationKey =  "sandbox_vtqbvdrz_kjjqnn2gj7vbds9g" // this is the tokenization key needed to authenticate with Braintree sandbox.  Since this is just a sandbox account, we have hard-coded the key in, but for production this key would need to be hosted elsewhere.
    // var centerMapped = false
    
    @IBOutlet weak var paymentButton: UIButton!

    //linking mapview to this class
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func showDirection(_ sender: Any) {
        
        //makes sure to get location from destination location rather than users current location
        guard let currentPlacemark = currentPlacemark else{
            return
        }
        let directionRequest = MKDirectionsRequest()
        let destinationPlacemark = MKPlacemark(placemark:currentPlacemark)
        
        
        //set source of the direction request
        directionRequest.source = MKMapItem.forCurrentLocation()
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        
        // determine the directions/route, and check for any errors along the way
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (directionsResponse, error) in
            //if directions response is nil, else case gets called
            guard let directionsResponse = directionsResponse else {
                if let error = error{
                    print("Error getting directions: \(error.localizedDescription)")
                }
                return
            }
            let route = directionsResponse.routes[0]
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.add(route.polyline, level: .aboveRoads)
            
            let routeRect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(routeRect), animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user1 = "DLB4aElaJ6WNr7V9593Ey1jPS023"
        
        let center = CLLocation(latitude: 37.77,  longitude: -122.41)  // Test Query on user locations to see who is found within a 100 mile radius.
        let circleQuery = geoFire.query(at: center, withRadius: 100)
        _ = circleQuery.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
            print("Found User: ", key!)  // print UID of users found.
        })
        let result = circleQuery.observeReady({})
        print("circleQueryResult =  \(result)")
        
         // print("Done Querying. ")
        
        let samplelocation = otherlocations(title: "sample location",
            locationName: "sample description",
            coordinate: CLLocationCoordinate2D(latitude: 42.3410, longitude: -83.0552))
                mapView.addAnnotation(samplelocation)
        
        // Query location from Firebase
        ref = Database.database().reference().child("Users") // Create reference to child node
        ref.child(user1).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get user value
            let value = snapshot.value as? NSDictionary
            let userLat = Double(value?["lat"] as? CLLocationDegrees ?? 0)
            let userLong = Double(value?["long"] as? CLLocationDegrees ?? 0)
            //let firstName = value?["firstName"] as? String ?? ""
            let lastName = value?["lastName"] as? String ?? ""
            print("User ID: ")
            print(user1)
            print("Saved Longitude: ")
            print(userLong)
            print("Saved Latitude: ")
            print(userLat)
            print("lastName: ")
            print(lastName)
        
            let databaseLocation = otherlocations(title: lastName,
                        locationName: lastName,
                        coordinate: CLLocationCoordinate2D(latitude: userLat, longitude: userLong))
            self.mapView.addAnnotation(databaseLocation)
        })
    
        // Set up Map
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        mapView.showsUserLocation = true
    }
    
    //selecting an annotation will call this method
    func mapView(_ mapView:MKMapView, didSelect view:MKAnnotationView)
    {
        //grab annotation form location
        let location = view.annotation as! otherlocations
        self.currentPlacemark = MKPlacemark(coordinate: location.coordinate)
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
            self.mapView.addAnnotation(annotation)
    
        })}


    //Brings up the user on the map after authorization
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
    }
    func locationAuthStatus () {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            mapView.showsUserLocation = true
            
        } else {
           locationManager.requestWhenInUseAuthorization()
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 7500, 7500)
        
        mapView.setRegion(coordinateRegion, animated: true)
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
                
            } else if let paymentResult = result {
                let selectedPaymentMethod = paymentResult.paymentMethod?.nonce // the nonce contains unique identifiers about the transaction that are needed by the server to process the transaction.
                
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
