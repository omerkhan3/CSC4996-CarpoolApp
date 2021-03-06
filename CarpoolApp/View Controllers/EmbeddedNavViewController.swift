// EmbeddedNav View Controller
// Created by Matt Prigorac on 4/1/18

import Foundation
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import FirebaseAuth

class EmbeddedNavViewController: UIViewController, NavigationViewControllerDelegate, UITextFieldDelegate, MGLMapViewDelegate  {

    var route: ScheduledRide?
    let userID = Auth.auth().currentUser!.uid
    //var mapView: NavigationMapView!
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var pickedUp: RoundedButton!
    @IBOutlet weak var droppedOff: RoundedButton!
    @IBOutlet weak var cancelDrive: RoundedButton!
    
    
    @IBAction func pickPress(_ sender: RoundedButton) {
        cancelDrive.alpha = 0.2
        pickedUp.alpha = 0.2
        var otherID = ""
        if (self.route?.driverID == self.userID){
            otherID = (self.route?.riderID)!
        }
        else{
            otherID = (self.route?.driverID)!
        }
        let rideInfo = ["otherID": otherID, "Date": self.route?.Date as Any, "matchID": self.route?.matchID as Any, "liveRideType": "riderPickedUp"] as [String:Any]
        self.setRideStatus(rideInfo: rideInfo)
    }
    
    @IBAction func dropPress(_ sender: RoundedButton) {
        cancelDrive.alpha = 1.0
        droppedOff.alpha = 0.2
        var otherID = ""
        if (self.route?.driverID == self.userID){
            otherID = (self.route?.riderID)!
        }
        else{
            otherID = (self.route?.driverID)!
        }
        let rideInfo = ["otherID": otherID, "Date": self.route?.Date as Any, "matchID": self.route?.matchID as Any, "liveRideType": "riderDroppedOff"] as [String:Any]
        self.setRideStatus(rideInfo: rideInfo)
        let ridePayment = ["driverID" : self.route!.driverID as Any, "riderID" : self.route!.riderID as Any, "rideCost": self.route!.rideCost as Any] as [String : Any]
        processPayment(ridePayment: ridePayment)
    }
    
    @IBAction func cancelPress(_ sender: RoundedButton) {
        
        var actionItem : String=String()
        var actionTitle : String=String()
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        // default action to exit out of native alerts.
        if cancelDrive.alpha != 1.0 {
            actionTitle = "Error!"
            actionItem = "You can not cancel ride in the middle of a route."
            
            // Activate UIAlertController to display error
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(exitAction)
            self.present(alert, animated: true, completion: nil)
        }
        else if cancelDrive.alpha == 1.0 {
             _ = self.navigationController?.popViewController(animated: true)
            print("hi")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateDirections()
        print(route!)
        //                                                                                                                                                                                 mapView = NavigationMapView(frame: view.bounds)
        //view.addSubview(mapView)
//        mapView.delegate = self
//        mapView.showsUserLocation = true
//        mapView.setUserTrackingMode(.follow, animated: true)
        
       
    }
    
    func navigationViewControllerDidCancelNavigation(_ navigationViewController: NavigationViewController) {
        var actionItem : String=String()
        var actionTitle : String=String()
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)  // default action to exit out of native alerts.
        actionTitle = "Warning!"
        actionItem = "You cannot use this button to exit navigation"
        
        // Activate UIAlertController to display error
        let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
        alert.addAction(exitAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func calculateDirections() {
        //   guard let userLocation = mapView?.userLocation!.location else {return}
        //   let userWaypoint = Waypoint(location: userLocation, heading: mapView?.userLocation?.heading, name: "user")
        if (route?.routeType == "toDestination")
            {
        let origin = Waypoint(coordinate: CLLocationCoordinate2DMake((route?.driverStartPointLat)!, (route?.driverStartPointLong)!))
        let destination = Waypoint(coordinate: CLLocationCoordinate2DMake((route?.driverEndPointLat)!, (route?.driverEndPointLong)!))
        let riderPickup = Waypoint(coordinate: CLLocationCoordinate2DMake((route?.riderStartPointLat)!, (route?.riderStartPointLong)!))
        let riderDropoff = Waypoint(coordinate: CLLocationCoordinate2DMake((route?.riderEndPointLat)!, (route?.riderEndPointLong)!))

        let options = NavigationRouteOptions(waypoints: [origin, riderPickup, riderDropoff, destination], profileIdentifier: . automobile)
        _ = Directions.shared.calculate(options) { (waypoints, routes, error) in
            guard let route2 = routes?.first, error == nil else {
                print(error!.localizedDescription)
                return
            }
            self.startEmbeddedNavigation(route2: route2)
        }
        }
            else{
            let origin = Waypoint(coordinate: CLLocationCoordinate2DMake((route?.driverEndPointLat)!, (route?.driverEndPointLong)!))
            let destination = Waypoint(coordinate: CLLocationCoordinate2DMake((route?.driverStartPointLat)!, (route?.driverStartPointLong)!))
            let riderPickup = Waypoint(coordinate: CLLocationCoordinate2DMake((route?.riderEndPointLat)!, (route?.riderEndPointLong)!))
            let riderDropoff = Waypoint(coordinate: CLLocationCoordinate2DMake((route?.riderStartPointLat)!, (route?.riderStartPointLong)!))

            let options = NavigationRouteOptions(waypoints: [origin, riderPickup, riderDropoff, destination], profileIdentifier: . automobile)
            _ = Directions.shared.calculate(options) { (waypoints, routes, error) in
                guard let route2 = routes?.first, error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                self.startEmbeddedNavigation(route2: route2)
            }
        }
    }
    
    func startEmbeddedNavigation(route2: Route) {
        let nav = NavigationViewController(for: route2)
        
        // simulate the route.
        nav.routeController.locationManager = SimulatedLocationManager(route: route2)
        
        nav.delegate = self
        addChildViewController(nav)
        container.addSubview(nav.view)
        nav.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nav.view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            nav.view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
            nav.view.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            nav.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
            ])
        self.didMove(toParentViewController: self)
    }
    //Do not remove!! for UI alerts when arriving at destinations
//    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
//
//        let alert = UIAlertController(title: "Arrived at \(String(describing: waypoint.name))", message: "Would you like to continue?", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
//            // Begin the next leg once the driver confirms
//            navigationViewController.routeController.routeProgress.legIndex += 1
//        }))
//        navigationViewController.present(alert, animated: true, completion: nil)
//
//        return false
//    }
    
    func setRideStatus(rideInfo: Dictionary<String, Any>)
    {
        let rideURL = URL(string: "http://141.217.48.208:3000/liveRide/")!
        var request = URLRequest(url: rideURL)
        let rideJSON = try! JSONSerialization.data(withJSONObject: rideInfo, options: .prettyPrinted)
        let rideJSONInfo = NSString(data: rideJSON, encoding: String.Encoding.utf8.rawValue)! as String
        request.httpBody = "rideInfo=\(rideJSONInfo)".data(using: String.Encoding.utf8)
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
    
    //Method to send unique payment nonce to server for transaction
    func processPayment (ridePayment: Dictionary<String, Any>) {
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print (error.localizedDescription)
                return;
            }
            //URL endpoint of our local node server
            let paymentURL = URL(string: "http://141.217.48.208:3000/payment/checkout")!
            var request = URLRequest(url: paymentURL)
            let ridePaymentJSON = try! JSONSerialization.data(withJSONObject: ridePayment, options: .prettyPrinted)
            let ridePaymentJSONInfo = NSString(data: ridePaymentJSON, encoding: String.Encoding.utf8.rawValue)! as String
            request.httpBody = "ridePayment=\(ridePaymentJSONInfo)".data(using: String.Encoding.utf8)
            request.httpMethod = "POST"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                //Error handling response
                if (error != nil){
                    print ("An error has occured.")
                }
                else{
                    print ("Success!")
                }
                }.resume()
        }
    }
}
