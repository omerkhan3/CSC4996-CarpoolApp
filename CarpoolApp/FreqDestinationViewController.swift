//
//  FreqDestinationViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 2/17/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import MapKit

class FreqDestinationViewController: UIViewController {
    
    //var searchCompleter = MKLocalSearchCompleter()
    //var searchResults = [MKLocalSearchCompletion]()
    
    @IBOutlet weak var HomeInput: UITableView!
    @IBOutlet weak var HomeSearchBar: UISearchBar!
    @IBOutlet weak var WorkInput: UITableView!
    @IBOutlet weak var WorkSearchBar: UISearchBar!
    @IBOutlet weak var SchoolInput: UITableView!
    @IBOutlet weak var SchoolSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    lazy var searchCompleter: MKLocalSearchCompleter = {
        let sC = MKLocalSearchCompleter()
        sC.delegate = self
        return sC
    }()
    var searchSource: [String]?
}

extension FreqDestinationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //change searchCompleter depends on searchBar's text
        if !searchText.isEmpty {
            searchCompleter.queryFragment = searchText
        }
    }
}

extension FreqDestinationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //I've created SearchCell beforehand; it might be your cell type
        let cell = self.tableVIew.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        
        cell.label.text = self.searchSource?[indexPath.row]
        //            + " " + searchResult.subtitle
        
        return cell
    }
}

extension FreqDestinationViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        //get result, transform it to our needs and fill our dataSource
        self.searchSource = completer.results.map { $0.title }
        DispatchQueue.main.async {
            self.tableVIew.reloadData()
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //handle the error
        print(error.localizedDescription)
    }
}
