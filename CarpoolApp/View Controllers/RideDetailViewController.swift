//
//  RideDetailViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/24/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import FirebaseAuth


class RideDetailViewController: UIViewController {
    
    // Class variables
    var scheduledRideDetail: ScheduledRide?
    let userID = Auth.auth().currentUser!.uid
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var pickupLocation: UILabel!
    @IBOutlet weak var pickupTime: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var departureTime: UILabel!
    @IBOutlet weak var cost: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(scheduledRideDetail!)
        setView()
    }

    @IBAction func mapOverview(_ sender: Any) {
    }
    
    
    @IBAction func cancelRide(_ sender: Any) {
    }
    
    func setView(){
        // If user is a driver populate rider name
        if userID == scheduledRideDetail?.driverID {
            //self.firstName.text = scheduledRideDetail?.riderFirstName
            
        } else {
            // Populate driver name
            //self.firstName.text = scheduledRideDetail?.riderFirstName
        }
        // Remaining information
        self.pickupLocation.text = "(rider home)"
        //self.pickupTime.text = scheduledRideDetail?.riderPickupTime
        self.destination.text = scheduledRideDetail?.riderRouteName
        //self.departureTime.text = scheduledRideDetail.riderPickupTime2
        //self.cost.text = scheduledRideDetail.cost
    }
        
}
