//
//  MyRoutesViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/27/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MyRoutesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Class Variables
    var destinationsArray = [FrequentDestination]()
    var destinationDetail: FrequentDestination?
    var myRoutesArray = [SavedRoutes]()
    var routeDetail : SavedRoutes?
    let userID = Auth.auth().currentUser?.uid
    let color = UIColor(red:0.00, green:0.59, blue:1.00, alpha:1.0)
    
    @IBOutlet weak var MyDestinationsTable: UITableView!
    @IBOutlet weak var noDestinationsLabel: UILabel!
    @IBOutlet weak var myRoutesTable: UITableView!
    @IBOutlet weak var noRoutesLabel: UILabel!
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    // UI Button Outlets
    @IBAction func editButton(_ sender: Any) {
        self.performSegue(withIdentifier: "showEditDestinations", sender: self)
    }
    
    @IBAction func addRoute(_ sender: Any) {
        if destinationsArray.count < 2 {
            let actionTitle = "Error!"
            let actionItem = "You must have at least 2 destinations saved before you can add a route."
            let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            // Activate UIAlertController to display error
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(exitAction)
            self.present(alert, animated: true, completion: nil)  // present error alert.
            
        }
        else{
        self.performSegue(withIdentifier: "showAddRoute", sender: self)
        }
    }
    
    //Reloading the table view and showing label if no saved routes
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myRoutesTable.reloadData()
        MyDestinationsTable.reloadData()
        
        getDestinationsDecode {
            self.MyDestinationsTable.reloadData()
            
            // Show or hide no saved routes alert
            if self.destinationsArray.count == 0 {
                // No saved routes
                self.noDestinationsLabel.isHidden = false
                self.MyDestinationsTable.isHidden = true
            }
            else {
                self.noDestinationsLabel.isHidden = true
                self.MyDestinationsTable.isHidden = false
            }
        }
        
        getMyRoutes {
            self.myRoutesTable.reloadData()
            
            // Show or hide no saved routes alert
            if self.myRoutesArray.count == 0 {
                // No saved routes
                self.noRoutesLabel.isHidden = false
                self.myRoutesTable.isHidden = true
            } else {
                self.noRoutesLabel.isHidden = true
                self.myRoutesTable.isHidden = false
            }
        }
        
        self.myRoutesTable.delegate = self
        self.myRoutesTable.dataSource = self
        self.MyDestinationsTable.delegate = self
        self.MyDestinationsTable.dataSource = self
    }
    
    // Class overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // Send data to other view controllers via segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddRoute" {
            if let frequentRoutesView = segue.destination as? FrequentRoutesViewController {
                frequentRoutesView.destinationsArray = destinationsArray
            } else {
                print("Data not passed")
            }
        } else {
            print("Segue id mismatch")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        if (tableView == myRoutesTable) {
            let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MyRoutesTableViewCell")
            
            cell.textLabel?.text = myRoutesArray[indexPath.row].Name
            cell.textLabel?.textColor = color
            cell.detailTextLabel?.text = "To:" + myRoutesArray[indexPath.row].endAddress
            
            return cell
        }
        else if (tableView == MyDestinationsTable) {
            let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MyDestinationsTableViewCell")
            
            cell.textLabel?.text = destinationsArray[indexPath.row].Name
            cell.textLabel?.textColor = color
            cell.detailTextLabel?.text = destinationsArray[indexPath.row].Address
            
            return cell
        }
        return cell
    }
    
    func deleteButtonPressed(sender: UIButton!){
        print("Deleted")
    }

    // Set number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = Int()
        
        if (tableView == myRoutesTable) {
           return myRoutesArray.count
        }
        else if (tableView == MyDestinationsTable) {
            return destinationsArray.count
        }
        return count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let userID = Auth.auth().currentUser!.uid
       // let routeid = self.routeDetail?.routeID
        
        if (tableView == MyDestinationsTable) {
            if editingStyle == .delete {
                let destinationID = destinationsArray[indexPath.row].frequentDestinationID
                destinationsArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                let deletingDestination = ["userID": userID, "frequentDestinationID": destinationID as Any]
                self.deleteDestination(deletingDestination: deletingDestination)
            }
        }
        if (tableView == myRoutesTable) {
            if editingStyle == .delete {
                print("removed row is \(myRoutesArray[indexPath.row].Name)")
                let goodRouteID = myRoutesArray[indexPath.row].routeID
                if myRoutesArray[indexPath.row].Matched == true {
                    let actionTitle = "Error!"
                    let actionItem = "You must cancel any scheduled rides associated with this route before deleting."
                    let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    // Activate UIAlertController to display error
                    let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                    alert.addAction(exitAction)
                    self.present(alert, animated: true, completion: nil)  // present error alert.
                } else {
                myRoutesArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                let cancelrouteInfo = ["routeID": goodRouteID as Any]
                self.cancelRoute(cancelrouteInfo: cancelrouteInfo)
                }
            }
        }
    }
    
    // Query all saved routes from database and, decode and store into an array
    func getMyRoutes(completed: @escaping () -> ()) {
        var viewMyRoutesComponents = URLComponents(string: "http://localhost:3000/routes/saved")!
        viewMyRoutesComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
        var request = URLRequest(url: viewMyRoutesComponents.url!)
        print (viewMyRoutesComponents.url!)
        
        // GET Method
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){
                print (error as Any)
            } else {
                guard let data = data else { return }
                do {
                    // Decode JSON
                    self.myRoutesArray = try JSONDecoder().decode([SavedRoutes].self, from: data)
                    print (self.myRoutesArray)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch let jsnERR {
                    print(jsnERR)
                }
            }
            }.resume()
    }

    // Function to download and save frequent destinations into an array
    func getDestinationsDecode(completed: @escaping () -> ()) {
        let userID = Auth.auth().currentUser?.uid
        var viewDestinationCompenents = URLComponents(string: "http://localhost:3000/freqDestinations/getDestination")!
        viewDestinationCompenents.queryItems = [URLQueryItem(name: "userID", value: userID)]
        var request = URLRequest(url: viewDestinationCompenents.url!)
        print (viewDestinationCompenents.url!)
        
        // GET Method
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){
                print (error as Any)
            } else {
                guard let data = data else { return }
                do {
                    // Decode JSON
                    self.destinationsArray = try JSONDecoder().decode([FrequentDestination].self, from: data)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch let jsnERR {
                    print(jsnERR)
                }
            }
            }.resume()
    }
    
    func deleteDestination(deletingDestination: Dictionary<String, Any>)
    {
        let deleteDestinationURL = URL(string: "http://localhost:3000/freqDestinations/deleteDestination")!
        var request = URLRequest(url: deleteDestinationURL)
        let deleteDestinationJSON = try! JSONSerialization.data(withJSONObject: deletingDestination, options: .prettyPrinted)
        let deletingDestinationJSONInfo = NSString(data: deleteDestinationJSON, encoding: String.Encoding.utf8.rawValue)! as String
        request.httpBody = "deletingDestination=\(deletingDestinationJSONInfo)".data(using: String.Encoding.utf8)
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
    
    func cancelRoute(cancelrouteInfo: Dictionary<String, Any>) {
        let cancelURL = URL(string: "http://localhost:3000/routes/cancelRoute")!
        var request = URLRequest(url: cancelURL)
        let cancelrouteJSON = try! JSONSerialization.data(withJSONObject: cancelrouteInfo, options: .prettyPrinted)
        let cancelrouteJSONInfo = NSString(data: cancelrouteJSON, encoding: String.Encoding.utf8.rawValue)! as String
        request.httpBody = "cancelrouteInfo=\(cancelrouteJSONInfo)".data(using: String.Encoding.utf8)
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
}
