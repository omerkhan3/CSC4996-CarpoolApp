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
    
    // Data outlets
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var pickupLocation: UILabel!
    @IBOutlet weak var pickupTime: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var departureTime: UILabel!
    @IBOutlet weak var cost: UILabel!
    
    // Label outlets
    @IBOutlet weak var pickupLbl: UILabel!
    @IBOutlet weak var destinationLbl: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(scheduledRideDetail!)
        setView()
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
            let actionTitle = "Cancel Single Ride"
            let actionItem = "Please confirm that you would like to cancel this single ride. This action cannot be undone!"
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
                // cancel single ride
                
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
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
                // cancel ride series
                
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
    
    func setView(){
        // If user is a driver populate rider name
        if userID == scheduledRideDetail?.driverID {
            self.firstName.text = scheduledRideDetail?.riderFirstName
            self.pickupLbl.text = "Rider Pickup Location"
            self.destinationLbl.text = "Rider Destination"
            
        } else {
            // Populate driver name
            self.firstName.text = scheduledRideDetail?.driverFirstName
        }
        // Remaining information
        self.pickupLocation.text = scheduledRideDetail?.riderStartAddress
        self.pickupTime.text = "\(String(describing: scheduledRideDetail?.riderPickupTime))"
        self.destination.text = scheduledRideDetail?.riderRouteName
        self.departureTime.text = "\(String(describing: scheduledRideDetail?.riderPickupTime2))" //string conversion
        //self.cost.text = scheduledRideDetail.cost
    }
    
    // Send data to map overview
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMapOverview1" {
            if let mapViewController = segue.destination as? MapViewController {
                mapViewController.scheduledRideDetail = scheduledRideDetail
                mapViewController.isScheduledRide = true
            }
        }
    }
        
}