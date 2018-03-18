//
//  RiderMatchDetailViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/6/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
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
        
        let userID = Auth.auth().currentUser!.uid
        let matchInfo = ["userID": userID, "matchID" : matchDetail?.matchID as Any, "requestType":  "riderRequest"] as [String : Any]
        
        riderRequest(matchInfo:  matchInfo)
        
        // Activate UIAlertController to display confirmation
        let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            //self.performSegue(withIdentifier: "showMatches2", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
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
            array = matchDetail?.riderDays
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
            self.requestButton.setTitle("CONFIRM RIDE", for: .normal)
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
