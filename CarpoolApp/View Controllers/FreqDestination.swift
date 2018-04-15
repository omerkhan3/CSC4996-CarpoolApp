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
    var destinationID: FrequentDestination?
    
    //Linking each table view and search bar
    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet weak var WorkLabel: UILabel!
    @IBOutlet weak var SchoolLabel: UILabel!
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
    
    @IBAction func saveButton(_ sender: Any) {
        var actionItem: String=String()
        var actionTitle: String=String()
        
        var destinations: [Dictionary<String, String>] = []
        
        let userID = Auth.auth().currentUser!.uid
        let homeInfo = ["userID": userID, "Name": self.HomeLabel.text! as String, "Address": self.HomeSearchBar.text! as String]
        let schoolInfo = ["userID": userID, "Name": self.SchoolLabel.text! as String, "Address": self.SchoolSearchBar.text! as String]
        let workInfo = ["userID": userID, "Name": self.WorkLabel.text! as String, "Address": self.WorkSearchBar.text! as String]
        let customInfo = ["userID": userID, "Name": self.otherInput.text! as String, "Address": self.otherSearchBar.text! as String]
        
        if (homeInfo["Address"] != nil && homeInfo["Address"] != "") {
            destinations.append(homeInfo)
        }
        if (schoolInfo["Address"] != nil && schoolInfo["Address"] != "") {
            destinations.append(schoolInfo)
        }
        if (workInfo["Address"] != nil && workInfo["Address"] != "") {
            destinations.append(workInfo)
        }
        if (customInfo["Address"] != nil && customInfo["Address"] != "") {
            destinations.append(customInfo)
        }
        
        //print(destinations)
        
        
        actionTitle = "Success!"
        actionItem = "Your frequent destinations have been saved"
        
        //Active UIAlertController to display error
        
        let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.saveDestinations(destinationInfo: destinations)
            self.performSegue(withIdentifier: "showMyRoutes", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
       
    }
    
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
        getDestinations(userID: userID!)
    }
    
    func getDestinations(userID: String) {
        var viewDestinationComponents = URLComponents(string: "http://localhost:3000/freqDestinations/getDestination")!
        viewDestinationComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewDestinationComponents.url!)  // Pass Parameter in URL
        print (viewDestinationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            }
            else if let data = data {
                print(data)
                let destinationInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = destinationInfoString.data(using: String.Encoding.utf8.rawValue) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String:AnyObject]]
                        print (json as Any)
                        //var JSONobjectLength = json.count
                        for data in json
                        {
                            if (data["Name"] as! String == "Home")
                            {
                                DispatchQueue.main.async
                                    {
                                        self.HomeSearchBar.text = (data["Address"] as? String)
                                }
                            }
                            else if (data["Name"] as! String == "School")
                            {
                                DispatchQueue.main.async
                                    {
                                        self.SchoolSearchBar.text = (data["Address"] as? String)
                                }
                            }
                            else if (data["Name"] as! String == "Work")
                            {
                                DispatchQueue.main.async
                                    {
                                        self.WorkSearchBar.text = (data["Address"] as? String)
                                }
                            }
                            else
                            {
                                DispatchQueue.main.async
                                    {
                                        self.otherInput.text = (data["Name"] as? String)
                                        self.otherSearchBar.text = (data["Address"] as? String)
                                }
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            }.resume()
    }
    
    func saveDestinations(destinationInfo: [Dictionary<String, String>])
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.WorkSearchBar.endEditing(true)
        self.SchoolSearchBar.endEditing(true)
        self.HomeSearchBar.endEditing(true)
        self.otherSearchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.WorkSearchBar.endEditing(true)
        self.SchoolSearchBar.endEditing(true)
        self.HomeSearchBar.endEditing(true)
        self.otherSearchBar.endEditing(true)
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
                HomeSearchBar.text = searchResult.title + ", " + searchResult.subtitle
                searchTable.isHidden = true
            }
            if tableView == searchTable2 {
                let searchResult = searchResults[indexPath.row]
                WorkSearchBar.text = searchResult.title + ", " + searchResult.subtitle
                searchTable2.isHidden = true
            }
            if tableView == searchTable3 {
                let searchResult = searchResults[indexPath.row]
                SchoolSearchBar.text = searchResult.title + ", " + searchResult.subtitle
                searchTable3.isHidden = true
            }
            if tableView == searchTable4 {
                let searchResult = searchResults[indexPath.row]
                otherSearchBar.text = searchResult.title + ", " + searchResult.subtitle
                searchTable4.isHidden = true
            }
        }
    }
