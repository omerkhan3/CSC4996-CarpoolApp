//
//  RideDetailViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/24/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

class RideDetailViewController: UIViewController {
    
    // Class variables
    var scheduledRideDetail: ScheduledRide?
    let userID = Auth.auth().currentUser!.uid
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    
    // Data outlets
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var pickupLocation: UILabel!
    @IBOutlet weak var pickupTime: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var departureTime: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var startRideBtn: RoundedButton!
    
    // Label outlets
    @IBOutlet weak var pickupLbl: UILabel!
    @IBOutlet weak var destinationLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        print(scheduledRideDetail!)
        setView()
        view.accessibilityIdentifier = "riderMatchDetail"
        databaseRef = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        if (userID == scheduledRideDetail?.driverID) {
            databaseRef.child("Users").child((scheduledRideDetail?.riderID)!).observeSingleEvent(of: .value, with: { (snapshot) in
                let dictionary = snapshot.value as? NSDictionary
                
                if let profileImageURL = dictionary?["Photo"] as? String {
                    let url = URL(string: profileImageURL)
                    URLSession.shared.dataTask(with: url!, completionHandler: {
                        (data, response, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async {
                            self.profilePicture.image = UIImage(data: data!)
                        }
                    }).resume()
                }
            }) { (error) in
                print(error.localizedDescription)
                return
            }
        }
        else {
            databaseRef.child("Users").child((scheduledRideDetail?.driverID)!).observeSingleEvent(of: .value, with: { (snapshot) in
                let dictionary = snapshot.value as? NSDictionary
                
                if let profileImageURL = dictionary?["Photo"] as? String {
                    let url = URL(string: profileImageURL)
                    URLSession.shared.dataTask(with: url!, completionHandler: {
                        (data, response, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async {
                            self.profilePicture.image = UIImage(data: data!)
                        }
                    }).resume()
                }
            }) { (error) in
                print(error.localizedDescription)
                return
            }
        }
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePicture.clipsToBounds = true
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
    }
    
    // Button actions
    @IBAction func startRide(_ sender: Any) {
        var otherID = ""
        if (self.scheduledRideDetail?.driverID == self.userID){
            otherID = (self.scheduledRideDetail?.riderID)!
        }
        else{
            otherID = (self.scheduledRideDetail?.driverID)!
        }
        let rideInfo = ["otherID": otherID, "Date": self.scheduledRideDetail?.Date as Any, "matchID": self.scheduledRideDetail?.matchID as Any, "liveRideType": "rideStarted"] as [String:Any]
        self.startRideStatus(rideInfo: rideInfo)
    }
    
    @IBAction func mapOverview(_ sender: Any) {
        self.performSegue(withIdentifier: "showMapOverview1", sender: self)
    }

    @IBAction func cancelRide(_ sender: Any) {
        let actionTitle = "Cancel Ride"
        let actionItem = "Would you like to cancel this single ride or the entire ride series?"
        
        // Cancel single ride option
        let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Single Ride", style: .default, handler: { action in
            // cancel single ride confirmation
            var otherID = ""
            if (self.scheduledRideDetail?.driverID == self.userID){
                otherID = (self.scheduledRideDetail?.riderID)!
            }
            else{
                otherID = (self.scheduledRideDetail?.driverID)!
            }
            
            let cancelInfo = ["otherID": otherID, "Date": self.scheduledRideDetail?.Date as Any, "matchID": self.scheduledRideDetail?.matchID as Any, "cancelType": "Individual"] as [String:Any]
            let actionTitle = "Cancel Single Ride"
            let actionItem = "Please confirm that you would like to cancel this single ride. This action cannot be undone!"
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
                // cancel single ride
                self.cancelRide(cancelInfo: cancelInfo)
                self.performSegue(withIdentifier: "showDashboardRideCancel", sender: self)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            }))
            
            self.present(alert, animated: true, completion: nil)
        }))
        
        // Cancel ride series option
        alert.addAction(UIAlertAction(title: "Ride Series", style: .default, handler: { action in
            // cancel ride series confirmation
            let actionTitle = "Cancel Ride Series"
            let actionItem = "Please confirm that you would like to cancel this ride series. This action cannot be undone!"
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            var otherID = ""
            if (self.scheduledRideDetail?.driverID == self.userID){
                otherID = (self.scheduledRideDetail?.riderID)!
            }
            else{
                otherID = (self.scheduledRideDetail?.driverID)!
            }
            let cancelInfo = ["otherID": otherID, "matchID": self.scheduledRideDetail?.matchID as Any, "riderRouteID": self.scheduledRideDetail?.riderRouteID as Any, "driverRouteID": self.scheduledRideDetail?.driverRouteID as Any, "cancelType": "Series"] as [String:Any]
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
                // cancel ride series
                self.cancelRide(cancelInfo: cancelInfo)
                self.performSegue(withIdentifier: "showDashboardRideCancel", sender: self)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            }))
            
            self.present(alert, animated: true, completion: nil)
        }))
        
        // Exit cancellation (do not cancel ride)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func cancelRide(cancelInfo: Dictionary<String, Any>) {
        let cancelURL = URL(string: "http://localhost:3000/routes/cancel")!
        var request = URLRequest(url: cancelURL)
        let cancelJSON = try! JSONSerialization.data(withJSONObject: cancelInfo, options: .prettyPrinted)
        let cancelJSONInfo = NSString(data: cancelJSON, encoding: String.Encoding.utf8.rawValue)! as String
        request.httpBody = "cancelInfo=\(cancelJSONInfo)".data(using: String.Encoding.utf8)
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
    
    func startRideStatus(rideInfo: Dictionary<String, Any>)
    {
        let rideURL = URL(string: "http://localhost:3000/liveRide/")!
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
    
    func setView(){
        // If user is a driver populate rider name
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: now as Date)
        formatter.dateFormat = "MMM d"
        let currentDate = formatter.string(from: now as Date)
        
        if scheduledRideDetail?.routeType == "toDestination"{
        if userID == scheduledRideDetail?.driverID {
            self.firstName.text = scheduledRideDetail?.riderFirstName
            self.pickupLbl.text = "Rider Pickup Location"
            self.destinationLbl.text = "Rider Destination"
            let startRideTime = getTime(date: scheduledRideDetail!.driverLeaveTime)
            let startRideInterval = getStartInterval(date: scheduledRideDetail!.driverLeaveTime)
            let rideDate = getDay(date: (scheduledRideDetail?.Date)!)
            print ("Current Time: ", currentTime, " Earliest Time to Start Ride: ", startRideInterval, "Driver Leave Time: ", startRideTime, "Ride Date: ", rideDate, "currentDate: ", currentDate)
            
            if (currentTime > startRideInterval && currentTime < startRideTime && rideDate == currentDate)
            {
               self.startRideBtn.isEnabled = true
            }
            else{
                self.startRideBtn.isHidden = true
            }
            
        } else {
            // Populate driver name
            self.firstName.text = scheduledRideDetail?.driverFirstName
            startRideBtn.isHidden = true
        }
        // Remaining information
            self.pickupLocation.text = String(describing: scheduledRideDetail!.riderStartAddress![..<(scheduledRideDetail!.riderStartAddress!.range(of: ",")!.lowerBound)])
            self.pickupTime.text = get12HourTime(date: (scheduledRideDetail?.riderPickupTime)!)
            self.destination.text = String(describing: scheduledRideDetail!.riderEndAddress![..<(scheduledRideDetail!.riderEndAddress!.range(of: ",")!.lowerBound)])
            self.departureTime.text =  get12HourTime(date: (scheduledRideDetail?.driverLeaveTime)!)
        self.cost.text = "$" + String(describing: Double(round(100 * scheduledRideDetail!.rideCost)/100))
        }
            
        else{
            if userID == scheduledRideDetail?.driverID {
                self.firstName.text = scheduledRideDetail?.riderFirstName
                self.pickupLbl.text = "Rider Pickup Location"
                self.destinationLbl.text = "Rider Destination"
                let startRideTime = getTime(date: scheduledRideDetail!.driverDepartureTime1)
                let startRideInterval = getStartInterval(date: scheduledRideDetail!.driverDepartureTime1)
                let rideDate = getDay(date: (scheduledRideDetail?.Date)!)
                
                print ("Current Time: ", currentTime, " Earliest Time to Start Ride: ", startRideInterval, "Driver Leave Time: ", startRideTime, "Ride Date: ", rideDate, "currentDate: ", currentDate)

                
                if (currentTime > startRideInterval && currentTime < startRideTime && rideDate == currentDate)
                {
                    self.startRideBtn.isEnabled = true
                }
                else{
                    self.startRideBtn.isHidden = true
                    
                }
                
            } else {
                // Populate driver name
                self.firstName.text = scheduledRideDetail?.driverFirstName
                startRideBtn.isHidden = true
            }
            // Remaining information
            self.pickupLocation.text = String(describing: scheduledRideDetail!.riderEndAddress![..<(scheduledRideDetail!.riderEndAddress!.range(of: ",")!.lowerBound)])
            self.pickupTime.text = get12HourTime(date: (scheduledRideDetail?.riderPickupTime2)!)
            self.destination.text = String(describing: scheduledRideDetail!.riderStartAddress![..<(scheduledRideDetail!.riderStartAddress!.range(of: ",")!.lowerBound)])
            self.departureTime.text =  get12HourTime(date: (scheduledRideDetail?.driverDepartureTime1)!)
            self.cost.text = "$" + String(describing: Double(round(100 * scheduledRideDetail!.rideCost)/100))
        }
    }
    
    // Send data to map overview
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMapOverview1" {
            if let mapViewController = segue.destination as? MapViewController {
                mapViewController.scheduledRideDetail = scheduledRideDetail
                mapViewController.isScheduledRide = true
            }
        }
        else if segue.identifier == "startNavigation" {
                if let embeddedNavViewController = segue.destination as? EmbeddedNavViewController {
                    embeddedNavViewController.route = scheduledRideDetail
                }
        }
    }
    
    
    func getTime(date: String) -> String {
        // Create date formatter and reformat date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        print(date)
        let formattedDate = dateFormatter.date(from: date)!
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: formattedDate)
        
        return dateString
    }
    
    
    func getDay(date: String) -> String {
        // Create date formatter and reformat date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        let formattedDate = dateFormatter.date(from: date)!
        dateFormatter.dateFormat = "MMM d"
        let dateString = dateFormatter.string(from: formattedDate)
        
        return dateString
    }
    
    func getStartInterval(date: String) -> String {
        // Create date formatter and reformat date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        print(date)
        var formattedDate = dateFormatter.date(from: date)!
        formattedDate = formattedDate.addingTimeInterval(-15.0 * 60)
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: formattedDate)
        return dateString
    }
    
    func get12HourTime(date: String) -> String {
        // Create date formatter and reformat date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        print(date)
        let formattedDate = dateFormatter.date(from: date)!
        dateFormatter.dateFormat = "h:mm a"
        let dateString = dateFormatter.string(from: formattedDate)
        
        return dateString
    }
}
