//
//  Location.swift
//  CarpoolApp
//
//  Created by muamer besic on 2/19/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseAuth

class FreqDestinations: UIViewController {
    
    //Used for search results being shown in table view and for table view to autocomplete address results
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    //Linking each table view and search bar
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var searchTable2: UITableView!
    @IBOutlet weak var searchTable3: UITableView!
    @IBOutlet weak var searchTable4: UITableView!
    @IBOutlet weak var otherInput: UITextField!
    @IBOutlet weak var otherSearchBar: UISearchBar!
    @IBOutlet weak var HomeSearchBar: UISearchBar!
    @IBOutlet weak var WorkSearchBar: UISearchBar!
    @IBOutlet weak var SchoolSearchBar: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //Array used for storing longitudes and latitudes
    var longitudeArray: [Double] = []
    var latitudeArray: [Double] = []
    //var destinationArray: [String] = []
    //var destinationsArray = [Destinations]()
    //var destinations = Destinations()
    
    //Save button for frequent destinations
    @IBAction func saveButton(_ sender: Any) {
        
        var actionItem: String=String()
        var actionTitle: String=String()
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

        let userID = Auth.auth().currentUser!.uid
        //self.homeLabel.text! = "Home"
        let routeInfo = ["userID": userID, "Name": self.homeLabel.text! as Any, "Address": self.HomeSearchBar.text! as Any]
        //print(routeInfo)
        saveFreqDestinations(routeInfo: routeInfo)
        actionTitle = "Success!"
        actionItem = "Your frequent destinations have been saved"
        
        let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
        alert.addAction(exitAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //Adding the extra input field when add button is pressed
    @IBAction func addInput(_ sender: UIButton) {
        otherInput.isHidden = false
        otherSearchBar.isHidden = false
        sender.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Table view will be hidden when getting onto the freq. destinations screen
        searchTable.isHidden = true
        searchTable2.isHidden = true
        searchTable3.isHidden = true
        searchTable4.isHidden = true
        otherInput.isHidden = true
        otherSearchBar.isHidden = true
        searchCompleter.delegate = self
        //Placeholder text for each search bar
        HomeSearchBar.placeholder = "Search for Places"
        WorkSearchBar.placeholder = "Search for Places"
        SchoolSearchBar.placeholder = "Search for Places"
        otherSearchBar.placeholder = "Search for Places"
    }
    
    //Posts the new inputted frequent destinations addresses in the database, encoding frequent destinations
    func saveFreqDestinations(routeInfo: Dictionary<String, Any>)
    {
        let editFreqDestinationURL = URL(string: "http://localhost:3000/freqDestinations/frequentDestinations")!
        var request = URLRequest(url: editFreqDestinationURL)
        let routeJSON = try! JSONSerialization.data(withJSONObject: routeInfo, options: .prettyPrinted)
        let routeJSONInfo = NSString(data: routeJSON, encoding: String.Encoding.utf8.rawValue)! as String
        request.httpBody = "routeInfo=\(routeJSONInfo)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST" // POST method.
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print ("An error has occured.")
            }
            else{
                print ("Success!")
                //print(routeInfo)
            }
            }.resume()
    }
}

    extension FreqDestinations: UISearchBarDelegate {
        
            func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            
                //When text is being inputted into search bar, table view will not be hidden depending on which search bar is clicked on
                if searchBar == HomeSearchBar {
                    searchTable.isHidden = false
                    searchTable2.isHidden = true
                    searchTable3.isHidden = true
                    searchTable4.isHidden = true
                }
                if searchBar == WorkSearchBar {
                    searchTable.isHidden = true
                    searchTable2.isHidden = false
                    searchTable3.isHidden = true
                    searchTable4.isHidden = true
                    otherInput.isHidden = true
                }
                if searchBar == SchoolSearchBar {
                    searchTable.isHidden = true
                    searchTable2.isHidden = true
                    searchTable3.isHidden = false
                    searchTable4.isHidden = true
                }
                if searchBar == otherSearchBar {
                    searchTable.isHidden = true
                    searchTable2.isHidden = true
                    searchTable3.isHidden = true
                    searchTable4.isHidden = false
                }
                
            searchCompleter.queryFragment = searchText
        }
    }
    
    extension FreqDestinations: MKLocalSearchCompleterDelegate {
        
        func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            searchResults = completer.results
            searchTable.reloadData()
            searchTable2.reloadData()
            searchTable3.reloadData()
            searchTable4.reloadData()
        }
        
        func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
            //When text is deleted in search bar, table view will be hidden
            searchTable.isHidden = true
            searchTable2.isHidden = true
            searchTable3.isHidden = true
            searchTable4.isHidden = true
        }
    }
    
    extension FreqDestinations: UITableViewDataSource {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return searchResults.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let searchResult = searchResults[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = searchResult.title
            cell.detailTextLabel?.text = searchResult.subtitle
            return cell
        }
    }
    
    extension FreqDestinations: UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            //If statements for selecting an address from table view and it showing up in search bar field as well as the table view disappearing after selection
            if tableView == searchTable {
                let searchResult = searchResults[indexPath.row]
                HomeSearchBar.text = searchResult.subtitle
                searchTable.isHidden = true
            }
            if tableView == searchTable2 {
                let searchResult = searchResults[indexPath.row]
                WorkSearchBar.text = searchResult.subtitle
                searchTable2.isHidden = true
            }
            if tableView == searchTable3 {
                let searchResult = searchResults[indexPath.row]
                SchoolSearchBar.text = searchResult.subtitle
                searchTable3.isHidden = true
            }
            if tableView == searchTable4 {
                let searchResult = searchResults[indexPath.row]
                otherSearchBar.text = searchResult.subtitle
                searchTable4.isHidden = true
            }
            
            //Outputs latitude and longtitude of selected place
            let completion = searchResults[indexPath.row]
            let searchRequest = MKLocalSearchRequest(completion: completion)
            let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                self.longitudeArray.append(Double( response!.mapItems[0].placemark.coordinate.longitude))
                self.latitudeArray.append(Double( response!.mapItems[0].placemark.coordinate.latitude))
                
                    //Not sure how to append the type i.e school, work, home address when new address is typed in
                //self.destinationArray.append(String(describing: Destinations.self))
            }
        }
    }
