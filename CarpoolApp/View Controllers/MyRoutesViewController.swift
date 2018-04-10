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
    let userID = Auth.auth().currentUser?.uid
    
    //Array used for retrieving the saved routes according to userID
    var myRoutesArray = [SavedRoutes]()
    
    @IBOutlet weak var MyDestinationsTable: UITableView!
    @IBOutlet weak var noDestinationsLabel: UILabel!
    @IBOutlet weak var myRoutesTable: UITableView!
    @IBOutlet weak var noRoutesLabel: UILabel!
    // UI Button Outlets
    @IBAction func editButton(_ sender: Any) {
        self.performSegue(withIdentifier: "showEditDestinations", sender: self)
    }
    

    @IBAction func addRoute(_ sender: Any) {
        self.performSegue(withIdentifier: "showAddRoute", sender: self)
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
            } else {
                self.noDestinationsLabel.isHidden = true
            }
        }
        
        getMyRoutes {
            self.myRoutesTable.reloadData()
            
            // Show or hide no saved routes alert
            if self.myRoutesArray.count == 0 {
                // No saved routes
                self.noRoutesLabel.isHidden = false
            } else {
                self.noRoutesLabel.isHidden = true
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
        
        /*getDestinationsDecode {
            print ("printing destinations array: ")
            print (self.destinationsArray)
        }*/
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
            cell.detailTextLabel?.text = myRoutesArray[indexPath.row].endAddress
            let deleteButton = UIButton()
            deleteButton.setImage(#imageLiteral(resourceName: "chris-tabbar-4-9"), for: .normal)
            deleteButton.frame = CGRect(x: 240, y: 15, width: 20, height: 20)
            deleteButton.addTarget(self, action: Selector(("deleteButtonPressed")), for: .touchUpInside)
            cell.addSubview(deleteButton)
            
            return cell
        }
        else if (tableView == MyDestinationsTable) {
            let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MyDestinationsTableViewCell")
            
            cell.textLabel?.text = destinationsArray[indexPath.row].Name
            cell.detailTextLabel?.text = destinationsArray[indexPath.row].Address
            let deleteButton = UIButton()
            deleteButton.setImage(#imageLiteral(resourceName: "chris-tabbar-4-9"), for: .normal)
            deleteButton.frame = CGRect(x: 240, y: 15, width: 20, height: 20)
            deleteButton.addTarget(self, action: Selector(("deleteButtonPressed")), for: .touchUpInside)
            cell.addSubview(deleteButton)
            
            let deletingDestination = ["userID": userID!, "Name": self.destinationsArray[indexPath.row].Name as Any, "Address": self.destinationsArray[indexPath.row].Address as Any]
            
            return cell
        }
        
        return cell

    }
    
    func deleteButtonPressed(sender: UIButton!){
        deleteDestination(deletingDestination: deletingDestination)
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
        if editingStyle == .delete {
            destinationsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
    
    // Custom class functions

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
}

