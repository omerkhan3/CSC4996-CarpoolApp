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
    
    //Save button for frequent destinations
    @IBAction func saveButton(_ sender: Any) {
        
        var actionItem: String=String()
        var actionTitle: String=String()
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

        let userID = Auth.auth().currentUser!.uid
        let homeInfo = ["userID": userID, "Name": self.homeLabel.text! as Any, "Address": self.HomeSearchBar.text! as Any]
        let schoolInfo = ["userID": userID, "Name": self.schoolLabel.text! as Any, "Address": self.SchoolSearchBar.text! as Any]
        let workInfo = ["userID": userID, "Name": self.workLabel.text! as Any, "Address": self.WorkSearchBar.text! as Any]
        let customInfo = ["userID": userID, "Name": self.otherInput.text! as Any, "Address": self.otherSearchBar.text! as Any]
        
        let destinations: [Dictionary<String, Any>] = [homeInfo, schoolInfo, workInfo, customInfo]
        
        print(destinations)
        
        saveDestinations(destinationInfo: destinations)
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
        
        let userID = Auth.auth().currentUser?.uid
        readHomeDestination(userID: userID!)
        readSchoolDestination(userID: userID!)
        readWorkDestination(userID: userID!)
        readCustomDestination(userID: userID!)
    }
    
    func readHomeDestination(userID: String)
    {
        var viewHomeDestinationComponents = URLComponents(string: "http://localhost:3000/freqDestinations/homeDestination")!
        viewHomeDestinationComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewHomeDestinationComponents.url!)  // Pass Parameter in URL
        print (viewHomeDestinationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            }
            else if let data = data {
                print(data)
                let homeInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = homeInfoString.data(using: String.Encoding.utf8.rawValue) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        print (json as Any)
                        if let homeInfo = json!["data"]
                        {
                            DispatchQueue.main.async {
                                self.HomeSearchBar.text = (homeInfo["Address"] as! String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            }.resume()
    }
    
    func readSchoolDestination(userID: String)
    {
        var viewSchoolDestinationComponents = URLComponents(string: "http://localhost:3000/freqDestinations/schoolDestination")!
        viewSchoolDestinationComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewSchoolDestinationComponents.url!)  // Pass Parameter in URL
        print (viewSchoolDestinationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            }
            else if let data = data {
                print(data)
                let schoolInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = schoolInfoString.data(using: String.Encoding.utf8.rawValue) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        print (json as Any)
                        if let schoolInfo = json!["data"]
                        {
                            DispatchQueue.main.async {
                                self.SchoolSearchBar.text = (schoolInfo["Address"] as! String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            }.resume()
    }
    
    func readWorkDestination(userID: String)
    {
        var viewWorkDestinationComponents = URLComponents(string: "http://localhost:3000/freqDestinations/workDestination")!
        viewWorkDestinationComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewWorkDestinationComponents.url!)  // Pass Parameter in URL
        print (viewWorkDestinationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            }
            else if let data = data {
                print(data)
                let workInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = workInfoString.data(using: String.Encoding.utf8.rawValue) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        print (json as Any)
                        if let workInfo = json!["data"]
                        {
                            DispatchQueue.main.async {
                                self.WorkSearchBar.text = (workInfo["Address"] as! String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            }.resume()
    }
    
    func readCustomDestination(userID: String)
    {
        var viewCustomDestinationComponents = URLComponents(string: "http://localhost:3000/freqDestinations/customDestination")!
        viewCustomDestinationComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewCustomDestinationComponents.url!)  // Pass Parameter in URL
        print (viewCustomDestinationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            }
            else if let data = data {
                print(data)
                let customInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = customInfoString.data(using: String.Encoding.utf8.rawValue) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        print (json as Any)
                        if let customInfo = json!["data"]
                        {
                            DispatchQueue.main.async {
                                self.otherSearchBar.text = (customInfo["Address"] as! String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            }.resume()
    }
    
    func saveDestinations(destinationInfo: [Dictionary<String, Any>])
    {
        let editDestinationURL = URL(string: "http://localhost:3000/freqDestinations/saveDestination")!
        var request = URLRequest(url: editDestinationURL)
        let destinationJSON = try! JSONSerialization.data(withJSONObject: destinationInfo, options: .prettyPrinted)
        let destinationJSONInfo = NSString(data: destinationJSON, encoding: String.Encoding.utf8.rawValue)! as String
        request.httpBody = "destinationInfo=\(destinationJSONInfo)".data(using: String.Encoding.utf8)
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
            }
        }
    }
