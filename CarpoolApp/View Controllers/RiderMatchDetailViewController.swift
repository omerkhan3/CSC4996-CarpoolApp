//
//  RiderMatchDetailViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/6/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import BEMCheckBox
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

class RiderMatchDetailViewController: UIViewController {
    
    // Class Variables
    var matchDetail: Match?
    var perfectRiderMatch = false
    var perfectDriverMatch = false
    var matchDaysArray = [String]()
    var driverDaysArray = [String]()
    var riderDaysArray = [String]()
    var matchStatus = ""
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!

    // Outlets
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var pickupTime: UILabel!
    @IBOutlet weak var pickupLocation: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var departureTime: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var requestButton: RoundedButton!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var matchScript: UILabel!
    
    @IBOutlet weak var sunday: BEMCheckBox!
    @IBOutlet weak var monday: BEMCheckBox!
    @IBOutlet weak var tuesday: BEMCheckBox!
    @IBOutlet weak var wednesday: BEMCheckBox!
    @IBOutlet weak var thursday: BEMCheckBox!
    @IBOutlet weak var friday: BEMCheckBox!
    @IBOutlet weak var saturday: BEMCheckBox!
    
    // Class method overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "UpcomingRideDetail"
        databaseRef = Database.database().reference()
        if let userID = Auth.auth().currentUser?.uid {
            databaseRef.child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
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
        loadProfileImage()
        
        print(matchDetail!)
        matchStatus = (matchDetail?.Status)!
        riderDaysArray = (matchDetail?.riderDays)!
        driverDaysArray = (matchDetail?.driverDays)!
        matchDaysArray = matchDays()
        print(matchDaysArray)
        fillCheckBoxes(daysArray: (matchDetail?.matchedDays)!)
        setView()
    }
    
    func loadProfileImage()
    {
        if let userID = Auth.auth().currentUser?.uid {
            databaseRef.child("Users").child(userID).observe(.value, with: { (snapshot) in
                let values = snapshot.value as? NSDictionary
                if let profileImageURL = values?["Photo"] as? String {
                    self.profilePicture.sd_setImage(with: URL(string: profileImageURL))
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMapOverview" {
            if let mapViewController = segue.destination as? MapViewController {
                mapViewController.mapMatchDetail = matchDetail
                mapViewController.isMatchDetail = true
            }
        }
    }

    @IBAction func requestConfirm(_ sender: Any) {
        let userID = Auth.auth().currentUser!.uid
        let matchID = self.matchDetail?.matchID
        let driverRouteID = self.matchDetail?.driverRouteID
        let riderRouteID = self.matchDetail?.riderRouteID
        
        // Rider request
        if matchStatus == "Awaiting rider request." {
            
            // Create POST dictionary
            let statusUpdate = ["userID": userID, "matchID": matchID!, "requestType": "riderRequest"] as [String : Any]
            
            // Alert: Have rider confirm they would like to submit the request
            let actionTitle = "Ride Request"
            let actionItem = "Please confirm that you would like to request this ride schedule."
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                // update match status
                self.riderRequest(matchInfo: statusUpdate)
                self.performSegue(withIdentifier: "showMatches3", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
        
            // Driver ride confirmation
            
            // Create POST dictionary
            let statusUpdate = ["userID": userID, "matchID": matchID!, "requestType": "driverRequested", "riderRouteID": riderRouteID as Any, "driverRouteID": driverRouteID as Any, "Days": matchDetail?.matchedDays as Any] as [String : Any]
            
            // Alert: have driver confirm ride request
            let actionTitle = "Confirm Ride"
            let actionItem = "Please confirm that you are agreeing to be a driver for the following request. Once confirmed, the corresponding rides will be scheduled and updated on your dashboard."
            
            // Activate UIAlertController to display confirmation
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                // update match status
                self.riderRequest(matchInfo: statusUpdate)
                self.performSegue(withIdentifier: "showDashboardFromMatch", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    
    // Custom class methods
    
    // Determine days matched / imperfect match
    func matchDays() -> [String] {
        let riderDaysSet = Set(riderDaysArray)
        let driverDaysSet = Set(driverDaysArray)
        perfectRiderMatch = riderDaysSet.isSubset(of: driverDaysSet)
        
        
        // Perfect Match
        if (perfectRiderMatch == true) {
            matchDaysArray = (matchDetail?.riderDays)!
            print("Rider days are covered")
            if (driverDaysArray == riderDaysArray) {
                perfectDriverMatch = true
            }
        } else {
            
            // Imperfect Match
            print("Rider Driver Days are the different")
            for riderDay in (matchDetail?.riderDays)! {
                for driverDay in (matchDetail?.driverDays)! {
                    if riderDay == driverDay {
                        matchDaysArray.append(riderDay)
                    }
                }
            }
        }
        
        print("rider days: ")
        print(self.matchDetail?.riderDays as Any)
        print("driver days: ")
        print(self.matchDetail?.driverDays as Any)
        print("match days: ")
        print(matchDaysArray)
        
        return matchDaysArray
    }
    
    func fillCheckBoxes(daysArray: [String]) {

        for item in daysArray {
            if item == "sunday" {
                self.sunday.on = true
            }
            else if item == "monday" {
                self.monday.on = true
            }
            else if item == "tuesday" {
                self.tuesday.on = true
            }
            else if item == "wednesday" {
                self.wednesday.on = true
            }
            else if item == "thursday" {
                self.thursday.on = true
            }
            else if item == "friday" {
                self.friday.on = true
            }
            else if item == "saturday" {
                self.saturday.on = true
            }
        }
    }
    
    func riderRequest(matchInfo: Dictionary<String, Any>)
    {
        let requestURL = URL(string: "http://localhost:3000/matches/approval")!
        var request = URLRequest(url: requestURL)
        let requestJSON = try! JSONSerialization.data(withJSONObject: matchInfo, options: .prettyPrinted)
        let requestJSONInfo = NSString(data: requestJSON, encoding: String.Encoding.utf8.rawValue)! as String
        request.httpBody = "requestInfo=\(requestJSONInfo)".data(using: String.Encoding.utf8)
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
        
        // Set view if rider has been matched with driver
        if matchStatus == "Awaiting rider request." {
            // Populate ride info
            //self.profilePicture ==
            self.firstName.text = matchDetail?.driverFirstName
            self.pickupTime.text = matchDetail?.riderPickupTime
            self.pickupLocation.text = matchDetail?.riderStartAddress
            self.destination.text = matchDetail?.driverRouteName
            self.departureTime.text = matchDetail?.driverLeaveTime
            self.cost.text = "$" + String(describing: Double(round(100 * matchDetail!.rideCost)/100))
            
            // Perfect Match
            if perfectRiderMatch == true {
                print("perfect rider match")
                
                // Alert: perfect match
                let actionTitle = "Awesome!"
                let actionItem = "You have a perfect match!"
                
                // Activate UIAlertController to display confirmation
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                }))
                self.present(alert, animated: true, completion: nil)
                
            // Imperfect Match
            } else {
                    print("Imperfect match")
                    
                    // Alert: imperfect match
                    let actionTitle = "Almost..."
                    let actionItem = "You haven't been matched for each day requested. You can still request these rides for now and we will continue trying to find other driver matches in the future."
                    
                    // Activate UIAlertController to display confirmation
                    let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
        }
            
        // Set view if driver has been requested by rider
        else if matchStatus == "driverRequested" {
            //Custom buttons and fields
            self.matchScript.text = "You have been requested as a driver on the following days:"
            self.requestButton.setTitle("CONFIRM RIDE", for: .normal)
            self.costLabel.text = "Earnings (One way)"
            
            // Populate ride info
            //self.profilePicture ==
            self.firstName.text = matchDetail?.driverFirstName
            self.pickupTime.text = matchDetail?.riderPickupTime
            self.pickupLocation.text = matchDetail?.riderStartAddress
            self.destination.text = matchDetail?.driverRouteName
            self.departureTime.text = matchDetail?.driverLeaveTime
            self.cost.text = "$" + String(describing: Double(round(100 * matchDetail!.rideCost)/100))
            
            // Imperfect match check
            if perfectDriverMatch == true {
                print("perfect match")
                
                // Alert: perfect match
                let actionTitle = "Awesome!"
                let actionItem = "You have a perfect match!"
                
                // Activate UIAlertController to display confirmation
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                }))
                self.present(alert, animated: true, completion: nil)
                
                // Imperfect Match
                } else {
                    print("Imperfect match")
                    
                    // Alert: imperfect match
                    let actionTitle = "Almost..."
                    let actionItem = "This rider is not requesting every day offered. You can still confirm these rides for now and we will notifiy you of other rider matches in the future."
                    
                    // Activate UIAlertController to display confirmation
                    let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
    }

}
