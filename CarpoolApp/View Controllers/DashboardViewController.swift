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
    var notificationsArray = [Notifications]()
    var payout = [UnpaidPayout]()
    
    // Outlets
    @IBOutlet weak var noRidesLabel: UILabel!
    @IBOutlet weak var ridesTableView: UITableView!
    @IBOutlet weak var payoutLbl: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.ridesTableView.delegate = self
        self.ridesTableView.dataSource = self
        self.payoutLbl.isHidden = true
        
        getNotifications {
            for notification in self.notificationsArray {
                if notification.Read == 0 {
                    // activate notification alert
                    let actionTitle = "You have new notifications!"
                    let actionItem = "Click on the notification icon in the upper right or got to notifications from the user menu to view."
                    
                    // Activate UIAlertController to display confirmation
                    let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        getPayout {
            if self.payout[0].sum > 0 {
                self.payoutLbl.isHidden = false
                self.payoutLbl.text = "Unpaid Payout: $ " + "\(self.payout[0].sum)"
            }
        }
        
        getScheduledRides {
            self.ridesTableView.reloadData()
            
            // Show or hide no schedules rides alert
            if self.scheduledRidesArray.count == 0 {
                // No scheduled rides
                self.ridesTableView.isHidden = true
                self.noRidesLabel.isHidden = false
            } else {
                self.ridesTableView.isHidden = false
                self.noRidesLabel.isHidden = true
            }
        }
        
        ridesTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "dashboardView"
        setupSideMenu()
        registerDeviceToken()
        ridesTableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showRideDetail" {
            if let rideDetailViewController = segue.destination as? RideDetailViewController {
                rideDetailViewController.scheduledRideDetail = scheduledRide
            }
        }
        
        if segue.identifier == "showNotifications" {
            if let notificationsViewController = segue.destination as? NotificationsTableViewController {
                notificationsViewController.notificationsArray = notificationsArray
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
        
        let cell = ridesTableView.dequeueReusableCell(withIdentifier: "rideCell") as! ScheduledRideTableViewCell
        
        // Create date formatter and reformat date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        print(self.scheduledRidesArray[indexPath.row].Date)
        let date = dateFormatter.date(from: scheduledRidesArray[indexPath.row].Date)!
        dateFormatter.dateFormat = "MM-dd-YYYY"
        let dateString = dateFormatter.string(from: date)
        
        // Set title based on whether the user is a rider or a driver for the ride
        if scheduledRidesArray[indexPath.row].driverID == userID {
            cell.rideIcon.image = UIImage(named: "driver-96")
            cell.drivingLbl.text = "Driving"
            cell.dateLbl.text = scheduledRidesArray[indexPath.row].Day.uppercased() + " " + dateString
            cell.nameLbl.text = "Rider: " + scheduledRidesArray[indexPath.row].riderFirstName
        } else {
            cell.rideIcon.image = UIImage(named: "passenger-96")
            cell.drivingLbl.text = "Riding"
            cell.dateLbl.text = scheduledRidesArray[indexPath.row].Day.uppercased() + " " + dateString
            cell.nameLbl.text = "Driver: " + scheduledRidesArray[indexPath.row].driverFirstName
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
        var viewScheduledRideComponents = URLComponents(string: "http://141.217.48.208:3000/routes/scheduled")!
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
    
    // Query undisbursed driver payments
    func getPayout(completed: @escaping () -> ()) {
        var viewPayoutComponents = URLComponents(string: "http://141.217.48.208:3000/payment/payout")!
        viewPayoutComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
        var request = URLRequest(url: viewPayoutComponents.url!)
        print (viewPayoutComponents.url!)

        // GET Method
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){
                print (error as Any)
            } else {
                guard let data = data else { return }
                do {
                    // Decode JSON
                    self.payout = try JSONDecoder().decode([UnpaidPayout].self, from: data)
                    print (self.payout)
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
        let editDeviceURL = URL(string: "http://141.217.48.208:3000/users/device")!
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
        
        let menuRightNavigationController = storyboard!.instantiateViewController(withIdentifier: "NotificationsTableViewController") as! UISideMenuNavigationController
        SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        menuRightNavigationController.menuWidth = UIScreen.main.bounds.width * 0.80

        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
    }

    // Download notifications JSON and decode into an array
    func getNotifications(completed: @escaping () -> ()) {
        let userID = Auth.auth().currentUser?.uid
        var viewNotificationComponents = URLComponents(string: "http://141.217.48.208:3000/notifications")!
        viewNotificationComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
        var request = URLRequest(url: viewNotificationComponents.url!)  // Pass Parameter in URL
        print (viewNotificationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            } else {
                guard let data = data else { return }
                do {
                    // decode JSON into Notifications[] array type
                    self.notificationsArray = try JSONDecoder().decode([Notifications].self, from: data)
                    print(self.notificationsArray)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch let jsnErr {
                    print(jsnErr)
                }
            }
            }.resume()
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
