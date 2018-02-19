//
//  LocationSearchTable.swift
//  CarpoolApp
//
//  Created by muamer besic on 2/18/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable : UITableViewController {
    //Matchingitems is for stashing search results and var mapview is for handling the map from previous screen
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate: MapSearch? = nil
    
    //Takes an entered address and converts it to a certain format created
    func parseAddress(selectedItem:MKPlacemark) -> String {
        //Puts a space between number and street
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        //Puts a comma between the street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        //Puts space between city and state
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            //Used for the street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            //Used for the street name
            selectedItem.thoroughfare ?? "",
            comma,
            //Used for the city
            selectedItem.locality ?? "",
            secondSpace,
            //Used for the city
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}

//Mklocalsearchrequest takes the entered string in search bar as well as the location pinpointed and Mklocalsearch is for performing the search entered in search bar and returns a response of an array of the location which is kept in the matchingitems and reload the table
extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

//This extension is for bringing together the different table inputs where it gets the matchingitems array which is for finding out how many table rows are there
extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
//The cells are configured with identifiers of cells in previous sections where textlabel is for the placemark name of the item on the map and the last part parses the address entered
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
}

//When a search item is chosen, you will get the placemark based on the chosen row which will be passed to the mapviewcontroller using the custom protocol which will then have the search results be closed that way the user can see the map
extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}

