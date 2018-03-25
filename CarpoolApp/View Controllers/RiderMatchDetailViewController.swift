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
    
    // Class Variables
    var matchDetail: Match?

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
    
    
    // Custom class methods
    
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
