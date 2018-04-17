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
    var match = Match()
        
    @IBOutlet weak var matchesTableView: UITableView!
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
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
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showRiderMatchDetail" {
                if let riderMatchDetailViewController = segue.destination as? RiderMatchDetailViewController {
                    riderMatchDetailViewController.matchDetail = match
                }
            }
        }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get row data
        match = matchesArray[indexPath.row]
            print(match)
        self.performSegue(withIdentifier: "showRiderMatchDetail", sender: self)
    }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = matchesTableView.dequeueReusableCell(withIdentifier: "matchCell") as! MatchesTableViewCell
            
            // set title based on notification type
            if matchesArray[indexPath.row].Status == "Awaiting rider request." {
                cell.matchLbl.text = "Matched with driver:  " + matchesArray[indexPath.row].driverFirstName
                cell.matchImage.image = UIImage(named: "driver-96")
            } else if matchesArray[indexPath.row].Status == "driverRequested" {
                cell.matchLbl.text = "Matched with rider:  " + matchesArray[indexPath.row].riderFirstName
                cell.matchImage.image = UIImage(named: "passenger-96")
            }
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
            var viewMatchComponents = URLComponents(string: "http://141.217.48.208:3000/matches")!
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
                        // decode JSON into Match[] array type
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
