//
//  Frequent Destinations.swift
//  CarpoolApp
//
//  Created by Matt on 2/17/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import BEMCheckBox
import MapKit
import Firebase
import FirebaseAuth

class FrequentDestinationsViewController: UIViewController, UIPickerViewDelegate, BEMCheckBoxDelegate  {

    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    var options = [String]()
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var arrivalButton: UIButton!
    @IBOutlet weak var departureButton: UIButton!
    @IBOutlet weak var placeButton: UIButton!
    @IBOutlet weak var placePicker: UIPickerView!
    
    @IBOutlet weak var sunday: BEMCheckBox!
    @IBOutlet weak var monday: BEMCheckBox!
    @IBOutlet weak var tuesday: BEMCheckBox!
    @IBOutlet weak var wednesday: BEMCheckBox!
    @IBOutlet weak var thursday: BEMCheckBox!
    @IBOutlet weak var friday: BEMCheckBox!
    @IBOutlet weak var saturday: BEMCheckBox!
    @IBOutlet weak var arrivaltime: UITextField!
    
    @IBOutlet weak var departtime: UITextField!
    
    @IBOutlet weak var HomeSearchBar: UISearchBar!
    @IBOutlet weak var WorkSearchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var searchTable2: UITableView!

    @IBOutlet weak var routeName: UITextField!
    let picker = UIDatePicker()
    
    let pickerData = ["work", "school", "gym"]
    var longitudeArray: [Float] = []
    var latitudeArray: [Float] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //pickerView.isHidden = true
       // pickerView.delegate = self
       // pickerView.dataSource = self
       // placePicker.isHidden = true
       // placePicker.delegate = self
       // placePicker.dataSource = self
        sunday.delegate = self
        monday.delegate = self
        tuesday.delegate = self
        wednesday.delegate = self
        thursday.delegate = self
        friday.delegate = self
        saturday.delegate = self
        
        searchTable.isHidden = true
        searchTable2.isHidden = true
        searchCompleter.delegate = self
        HomeSearchBar.placeholder = "Search for Places"
        WorkSearchBar.placeholder = "Search for Places"
       
    }
                
    @IBOutlet weak var driverSetting: UISwitch!
    
    
    
    
    @IBAction func arrivalpress(_ sender: UITextField) {
        createDatePicker1()
        
    }
    
    
    @IBAction func departpress(_ sender: UITextField) {
        createDatePicker2()
    }
    
    
    func createDatePicker1() {
        
        // toolbar
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed1))
        toolbar.setItems([done], animated: false)
        
        arrivaltime.inputAccessoryView = toolbar
       arrivaltime.inputView = picker
        
        // format picker for date
        picker.datePickerMode = .time
    }
    
    @objc func donePressed1() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let dateString = formatter.string(from: picker.date)
        
        arrivaltime.text = "\(dateString)"
        self.view.endEditing(true)
        
    }
    
    func createDatePicker2() {
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar picker
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed2))
        toolbar.setItems([done], animated: false)
        
        departtime.inputAccessoryView = toolbar
        departtime.inputView = picker
        
        // format second picker for time
        picker.datePickerMode = .time
    }
    
    @objc func donePressed2() {
        // format time using dateformatter
        let formatter = DateFormatter()
        // takes date off of the picker
        formatter.dateStyle = .none
        // allows for only HH:MM and am or pm
        formatter.timeStyle = .short
        // formatting the time into a string
        let dateString = formatter.string(from: picker.date)
        // adding the selected time back to the label
        departtime.text = "\(dateString)"
        
        self.view.endEditing(true)
        
    }
    
    
//    @IBAction func placePress(_ sender: UIButton) {
//        if placePicker.isHidden{
//            placePicker.isHidden = false
//        }    }
//
//
//
//   //  returns the number of 'columns' to display.
//
//    public func numberOfComponents(in placePicker: UIPickerView) -> Int {
//        return 1
//
//    }
//    // returns the # of rows in each component..
//
//    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return pickerData.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return pickerData[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//             placeButton.setTitle(pickerData[row], for: .normal)
//            placePicker.isHidden = true
//
//
//    }
    
   
    
    func didTap(_ checkBox: BEMCheckBox) {
        switch checkBox {
        case sunday:
            addRemoveOption(forState: checkBox.on, option: "sunday")
        case monday :
            addRemoveOption(forState: checkBox.on, option: "monday")
        case tuesday :
            addRemoveOption(forState: checkBox.on, option: "tuesday")
        case wednesday :
            addRemoveOption(forState: checkBox.on, option: "wednesday")
        case thursday :
            addRemoveOption(forState: checkBox.on, option: "thursday")
        case friday :
            addRemoveOption(forState: checkBox.on, option: "friday")
        case saturday :
            addRemoveOption(forState: checkBox.on, option: "saturday")
        default:
            addRemoveOption(forState: checkBox.on, option: "none")
        }
        
    }
    func addRemoveOption(forState : Bool , option : String)
    {
        switch forState
        {
        case true:
            options += [option]
            dump(options)
        case false:
            if let index = options.index(of: option)
            {
                options.remove(at: index)
            }
            
        }
    }
    @IBAction func actionSubmit(_ sender : Any)
    {
        dump(options)
        print(options.joined(separator: ", "))
        let driver = self.driverSetting.isOn
        let userID = Auth.auth().currentUser!.uid
        let routeInfo = ["userID": userID, "departureTime": departtime.text! as Any, "arrivalTime" : arrivaltime.text! as Any, "Days" :  options, "Longitudes": longitudeArray, "Latitudes": latitudeArray, "Driver": driver, "Name": self.routeName.text! as Any] as [String : Any]
        print (routeInfo)
        addRoute(routeInfo: routeInfo)
      //  print(arrivaltime.text)
       // print(departtime.text)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

func addRoute(routeInfo: Dictionary<String, Any>)
{
    let routeURL = URL(string: "http://localhost:3000/routes/")!
    var request = URLRequest(url: routeURL)
    let userJSON = try! JSONSerialization.data(withJSONObject: routeInfo, options: .prettyPrinted)
    let userJSONInfo = NSString(data: userJSON, encoding: String.Encoding.utf8.rawValue)! as String
    request.httpBody = "userInfo=\(userJSONInfo)".data(using: String.Encoding.utf8)
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

extension FrequentDestinationsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //When text is being inputted into search bar, table view will not be hidden depending on which search bar is clicked on
        if searchBar == HomeSearchBar {
            searchTable.isHidden = false
            searchTable2.isHidden = true
        }
        if searchBar == WorkSearchBar {
            searchTable.isHidden = true
            searchTable2.isHidden = false
        }
        searchCompleter.queryFragment = searchText
    }
}

extension FrequentDestinationsViewController: MKLocalSearchCompleterDelegate{
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    searchResults = completer.results
    searchTable.reloadData()
    searchTable2.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    //When text is deleted in search bar, table view will be hidden
    searchTable.isHidden = true
    searchTable2.isHidden = true
    }
}

extension FrequentDestinationsViewController: UITableViewDataSource {
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

extension FrequentDestinationsViewController: UITableViewDelegate {
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
        
        //Outputs latitude and longtitude of selected place
        let completion = searchResults[indexPath.row]
        let searchRequest = MKLocalSearchRequest(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            self.longitudeArray.append(Float( response!.mapItems[0].placemark.coordinate.longitude))
            self.latitudeArray.append(Float( response!.mapItems[0].placemark.coordinate.latitude))
            
           // print(String(describing: coordinate))
        }
    }
}


