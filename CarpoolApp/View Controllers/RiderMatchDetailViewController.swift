//
//  RiderMatchDetailViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/6/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import BEMCheckBox

class RiderMatchDetailViewController: UIViewController {
    
    var matchDetail: Match?

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var pickupTime: UILabel!
    @IBOutlet weak var pickupLocation: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var departureTime: UILabel!
    @IBOutlet weak var cost: UILabel!
    
    // Check boxes
    @IBOutlet weak var sunday: BEMCheckBox!
    @IBOutlet weak var monday: BEMCheckBox!
    @IBOutlet weak var tuesday: BEMCheckBox!
    @IBOutlet weak var wednesday: BEMCheckBox!
    @IBOutlet weak var thursday: BEMCheckBox!
    @IBOutlet weak var friday: BEMCheckBox!
    @IBOutlet weak var saturday: BEMCheckBox!
    

    
    @IBAction func requestRide(_ sender: Any) {
        let actionTitle = "Ride Request"
        let actionItem = "Your ride request has been sent to the driver! You will be notified if your ride is confirmed."
        
        // Activate UIAlertController to display confirmation
        let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            //self.performSegue(withIdentifier: "showMatches2", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(matchDetail!)
        fillCheckBoxes()
        self.firstName.text = matchDetail?.driverFirstName
        self.destination.text = matchDetail?.driverRouteName
        //self.time.text = matchDetail?.driverArrival

        // Do any additional setup after loading the view.
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
        let array = matchDetail?.driverDays
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

}
