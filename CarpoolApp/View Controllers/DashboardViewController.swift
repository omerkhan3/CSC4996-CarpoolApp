//
//  DashboardViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/3/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import SideMenu
import FirebaseAuth

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Class variables
    var scheduledRidesArray = [ScheduledRide]()
    var scheduledRide = ScheduledRide()
    let userID = Auth.auth().currentUser?.uid
    
    // Outlets
    @IBOutlet weak var noRidesLabel: UILabel!
    @IBOutlet weak var ridesTableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ridesTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
        registerDeviceToken()
        
        getScheduledRides {
            self.ridesTableView.reloadData()
            
            // Show or hide no schedules rides alert
            if self.scheduledRidesArray.count == 0 {
                // No scheduled rides
                self.noRidesLabel.isHidden = false
            } else {
                self.noRidesLabel.isHidden = true
            }
        }
        
        self.ridesTableView.delegate = self
        self.ridesTableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showRideDetail" {
            if let rideDetailViewController = segue.destination as? RideDetailViewController {
                rideDetailViewController.scheduledRideDetail = scheduledRide
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Prepare scheduled ride information for segue
        scheduledRide = scheduledRidesArray[indexPath.row]
        print(scheduledRide)
        
        // Segue to Match/Ride detail view
        self.performSegue(withIdentifier: "showRideDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "rideCell")
        
        // Create date formatter and reformat date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        let date = dateFormatter.date(from: scheduledRidesArray[indexPath.row].Date)!
        dateFormatter.dateFormat = "MM-dd-YYYY"
        let dateString = dateFormatter.string(from: date)
        
        // Set title based on whether the user is a rider or a driver for the ride
        if scheduledRidesArray[indexPath.row].driverID == userID {
            cell.textLabel?.text = "Driving on: " + scheduledRidesArray[indexPath.row].Day.uppercased()
            cell.detailTextLabel?.text = dateString
        } else {
            cell.textLabel?.text = "Riding on:  " + scheduledRidesArray[indexPath.row].Day.uppercased()
            cell.detailTextLabel?.text = dateString
        }
        return cell
    }
    
    // Set number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduledRidesArray.count
    }
    
    
    // Query all scheduled rides from database and, decode and store into an array
    func getScheduledRides(completed: @escaping () -> ()) {
        var viewScheduledRideComponents = URLComponents(string: "http://localhost:3000/routes/scheduled")!
        viewScheduledRideComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
        var request = URLRequest(url: viewScheduledRideComponents.url!)
        print (viewScheduledRideComponents.url!)
        
        // GET Method
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){
                print (error as Any)
            } else {
                guard let data = data else { return }
                do {
                    // Decode JSON
                    self.scheduledRidesArray = try JSONDecoder().decode([ScheduledRide].self, from: data)
                    print (self.scheduledRidesArray)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch let jsnERR {
                    print(jsnERR)
                }
            }
        }.resume()
    }
    
    func registerDeviceToken()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //print("Device Token:", appDelegate.deviceToken)
        if ((appDelegate.deviceToken?.isEmpty)!)
        {
            print ("Device already registered.")
        }
        else
        {
            let userInfo = ["userID": Auth.auth().currentUser?.uid as Any,   "deviceToken" : appDelegate.deviceToken] as [String:Any]
            updateDevice(userInfo : userInfo)
        }
        
    }
    
    
    func updateDevice(userInfo: Dictionary<String, Any>)
    {
        let editDeviceURL = URL(string: "http://141.217.48.15:3000/users/device")!
        var request = URLRequest(url: editDeviceURL)
        let userJSON = try! JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        let userJSONInfo = NSString(data: userJSON, encoding: String.Encoding.utf8.rawValue)! as String
        request.httpBody = "userInfo=\(userJSONInfo)".data(using: String.Encoding.utf8)
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

    fileprivate func setupSideMenu() {
        // Define the menus
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "UserMenuNavigationController") as? UISideMenuNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        // Set up a cool background image for demo purposes
        //SideMenuManager.default.menuAnimationBackgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }
}
    
extension DashboardViewController: UISideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
    }
    
    func sideMenuDidAppear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")
    }
    
    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")
    }
        
}

