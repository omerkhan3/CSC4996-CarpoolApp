//
//  Location.swift
//  CarpoolApp
//
//  Created by muamer besic on 2/19/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import MapKit

class FreqDestinations: UIViewController {
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var searchTable2: UITableView!
    @IBOutlet weak var searchTable3: UITableView!
    @IBOutlet weak var searchTable4: UITableView!
    @IBOutlet weak var otherInput: UITextField!
    @IBOutlet weak var otherSearchBar: UISearchBar!
    @IBOutlet weak var HomeSearchBar: UISearchBar!
    @IBOutlet weak var WorkSearchBar: UISearchBar!
    @IBOutlet weak var SchoolSearchBar: UISearchBar!
    
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
            // handle error
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
            
            //Needs fixing to not have it output mklocalsearch blah blah blah before address in search bar
            if tableView == searchTable {
                let searchResult = searchResults[indexPath.row]
                HomeSearchBar.text = searchResult.description
                searchTable.isHidden = true
            }
            if tableView == searchTable2 {
                let searchResult = searchResults[indexPath.row]
                WorkSearchBar.text = searchResult.description
                searchTable2.isHidden = true
            }
            if tableView == searchTable3 {
                let searchResult = searchResults[indexPath.row]
                SchoolSearchBar.text = searchResult.description
                searchTable3.isHidden = true
            }
            if tableView == searchTable4 {
                let searchResult = searchResults[indexPath.row]
                otherSearchBar.text = searchResult.description
                searchTable4.isHidden = true
            }
        }
    }
