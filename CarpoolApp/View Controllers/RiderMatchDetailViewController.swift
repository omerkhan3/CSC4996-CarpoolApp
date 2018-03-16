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

class RiderMatchDetailViewController: UIViewController {
    
    var matchDetail: Match?

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
    
    // Check boxes
    @IBOutlet weak var sunday: BEMCheckBox!
    @IBOutlet weak var monday: BEMCheckBox!
    @IBOutlet weak var tuesday: BEMCheckBox!
    @IBOutlet weak var wednesday: BEMCheckBox!
    @IBOutlet weak var thursday: BEMCheckBox!
    @IBOutlet weak var friday: BEMCheckBox!
    @IBOutlet weak var saturday: BEMCheckBox!
    

    // Used for both ride request or confirmation
    @IBAction func requestRide(_ sender: Any) {
        let userID = Auth.auth().currentUser!.uid
        let matchID = self.matchDetail?.matchID
        
        // Rider request
        if matchDetail?.Status == "Awaiting rider request." {
            // Create POST dictionary
            let statusUpdate = ["userID": userID, "matchID": matchID!, "requestType": "riderRequest"] as [String : Any]
            
            // Alert: Have rider confirm they would like to submit the request
            let actionTitle = "Ride Request"
            let actionItem = "Please confirm that you would like to request this ride schedule."
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                // update match status
                let updateMatchURL = URL(string: "http://localhost:3000/matches/approval")!
                var request = URLRequest(url: updateMatchURL)
                print(request)
                let statusJSON = try! JSONSerialization.data(withJSONObject: statusUpdate, options: .prettyPrinted)
                let statusJSONInfo = NSString(data: statusJSON, encoding: String.Encoding.utf8.rawValue)! as String
                request.httpBody = "requestInfo=\(statusJSONInfo)".data(using: String.Encoding.utf8)
                request.httpMethod = "POST" // POST method.
                
                URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                    if (error != nil){  // error handling responses.
                        print ("An error has occured.")
                    }
                    else{
                        print ("Success!")
                    }
                    
                    }.resume()
                self.performSegue(withIdentifier: "showMatches2", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
        }
            
        // Driver ride confirmation
        else {
            // Create POST dictionary
            let statusUpdate = ["userID": userID, "matchID": matchID!, "requestType": "driverRequested"] as [String : Any]
            
            // Alert: have driver confirm ride request
            let actionTitle = "Confirm Ride"
            let actionItem = "Please confirm that you are agreeing to be a driver for the following request. Once confirmed, the corresponding rides will be scheduled and updated on your dashboard."
            
            // Activate UIAlertController to display confirmation
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                // update match status
                let updateMatchURL = URL(string: "http://localhost:3000/matches/approval")!
                var request = URLRequest(url: updateMatchURL)
                print(request)
                let statusJSON = try! JSONSerialization.data(withJSONObject: statusUpdate, options: .prettyPrinted)
                let statusJSONInfo = NSString(data: statusJSON, encoding: String.Encoding.utf8.rawValue)! as String
                request.httpBody = "requestInfo=\(statusJSONInfo)".data(using: String.Encoding.utf8)
                request.httpMethod = "POST" // POST method.
                
                URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                    if (error != nil){  // error handling responses.
                        print ("An error has occured.")
                    }
                    else{
                        print ("Success!")
                    }
                    
                    }.resume()
                self.performSegue(withIdentifier: "showMatches2", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(matchDetail!)
        fillCheckBoxes()
        setView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMapOverview" {
            if let mapViewController = segue.destination as? MapViewController {
                mapViewController.mapMatchDetail = matchDetail
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillCheckBoxes() {
        var array: [String]?
        if matchDetail?.Status == "Awaiting rider request." {
            // Rider has been matched with driver
            array = matchDetail?.driverDays
        } else {
            // Driver has been requested by rider
            //array = matchDetail?.riderDays
        }
        for item in array! {
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
    
    func setView(){
        // Set view if rider has been matched with driver
        if matchDetail?.Status == "Awaiting rider request." {
            // Populate ride info
            //self.profilePicture ==
            self.firstName.text = matchDetail?.driverFirstName
            //self.pickupTime.text =
            //self.pickupLocation =
            self.destination.text = matchDetail?.driverRouteName
            //self.departureTime.text =
            //self.cost.text =
        }
        // Set view if driver has been requested by rider
        else if matchDetail?.Status == "driverRequested" {
            //Custom buttons and fields
            self.matchScript.text = "You have been requested as a driver on the following days:"
            self.requestButton.setTitle("Confirm Ride", for: .normal)
            self.costLabel.text = "Earnings (One way)"
            
            // Populate ride info
            //self.profilePicture ==
            self.firstName.text = matchDetail?.driverFirstName
            //self.pickupTime.text =
            //self.pickupLocation =
            self.destination.text = matchDetail?.driverRouteName
            //self.departureTime.text =
            //self.cost.text =
        }
    }

}
