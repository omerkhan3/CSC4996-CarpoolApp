//
//  MatchesViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/5/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MatchesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

        
        // array of matches
        var matchesArray = [Match]()
        
    @IBOutlet weak var matchesTableView: UITableView!
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            matchesTableView.reloadData()
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            getMatches {
                self.matchesTableView.reloadData()
                if self.matchesArray.count == 0 {
                    // No notifications alert
                    let actionTitle = "Uh oh.."
                    let actionItem = "You have no matches!"
                    
                    // Activate UIAlertController to display confirmation
                    let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            self.matchesTableView.delegate = self
            self.matchesTableView.dataSource = self
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "matchCell")
            
            // set title to notification type
            cell.textLabel?.text = "Driver:  " + matchesArray[indexPath.row].driverFirstName
            cell.detailTextLabel?.text = "Riding to: " + matchesArray[indexPath.row].driverRouteName.capitalized
            return cell
        }
        
        // set number of sections
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        // set number of rows
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return matchesArray.count
        }
        
        // Download notifications JSON and decode into an array
        func getMatches(completed: @escaping () -> ()) {
            // get userID
            let userID = Auth.auth().currentUser?.uid
            var viewMatchComponents = URLComponents(string: "http://localhost:3000/matches")!
            viewMatchComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
            var request = URLRequest(url: viewMatchComponents.url!)  // Pass Parameter in URL
            print (viewMatchComponents.url!)
            
            request.httpMethod = "GET" // GET METHOD
            URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                if (error != nil){  // error handling responses.
                    print (error as Any)
                } else {
                    guard let data = data else { return }
                    do {
                        // decode JSON into Notifications[] array type
                        self.matchesArray = try JSONDecoder().decode([Match].self, from: data)
                        print(self.matchesArray)
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
