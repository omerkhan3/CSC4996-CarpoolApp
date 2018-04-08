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
    
    // UI Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var UserHomeAddress: UILabel!
    @IBOutlet weak var UserSchoolAddress: UILabel!
    @IBOutlet weak var UserWorkAddress: UILabel!
    @IBOutlet weak var UserOtherAddress: UILabel!
    @IBOutlet weak var otherDestination: UILabel!
    
    //Array used for retrieving the saved routes according to userID
    var myRoutesArray = [SavedRoutes]()
    let userID = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var myRoutesTable: UITableView!
    @IBOutlet weak var noRoutesLabel: UILabel!
    // UI Button Outlets
    @IBAction func editButton(_ sender: Any) {
        self.performSegue(withIdentifier: "showEditDestinations", sender: self)
    }
    

    @IBAction func addRoute(_ sender: Any) {
        self.performSegue(withIdentifier: "showAddRoutes", sender: self)
    }
    
    //Reloading the table view and showing label if no saved routes
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myRoutesTable.reloadData()
        
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
    }
    
    // Class overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        //let userID = Auth.auth().currentUser?.uid
        //getDestinations(userID: userID!)
        getDestinationsDecode {
            print ("printing destinations array: ")
            print (self.destinationsArray)
            self.showDestinations()
        }
        UserHomeAddress.isHidden = true
        UserSchoolAddress.isHidden = true
        UserWorkAddress.isHidden = true
        UserOtherAddress.isHidden = true
    }
    
    // Send data to other view controllers via segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddRoute" {
            if let frequentRoutesView = segue.destination as? FrequentDestinationsViewController {
                frequentRoutesView.destinationsArray = destinationsArray
            } else {
                print("Data not passed")
            }
        } else {
            print("Segue id mismatch")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MyRoutesTableViewCell")
        
        cell.textLabel?.text = myRoutesArray[indexPath.row].Name
        cell.detailTextLabel?.text = myRoutesArray[indexPath.row].endAddress
        
        return cell
    }
    
    // Set number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myRoutesArray.count
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
    
    // Function to load frequent destinations onto the view
    func showDestinations() -> Void {
        for destination in destinationsArray {
            
            // Show home destination if saved
            if (destination.Name == "Home") {
                self.UserHomeAddress.isHidden = false
                self.UserHomeAddress.text = destination.Address
                            
            }
                
            // Show school destination if saved
            else if (destination.Name == "School")
            {
                self.UserSchoolAddress.isHidden = false
                self.UserSchoolAddress.text = destination.Address
            }
            
            // Show Work destination if saved
            else if (destination.Name == "Work")
            {
                self.UserWorkAddress.isHidden = false
                self.UserWorkAddress.text = destination.Address
            
            // Show custom destination if saved
            } else {
                self.UserOtherAddress.isHidden = false
                self.otherDestination.text = destination.Name
                self.UserOtherAddress.text = destination.Address
            }
        }
    }
}

