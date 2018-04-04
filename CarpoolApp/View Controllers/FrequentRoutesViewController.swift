//
//  Frequent Routes.swift
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

class FrequentRoutesViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, BEMCheckBoxDelegate, UITextFieldDelegate  {
    
    var destinationsArray = [FrequentDestination]()
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    let picker = UIDatePicker()
    let dist = -190
    
    
    var longitudeArray: [Float] = []
    var latitudeArray: [Float] = []
    var options = [String]()
    let pickerData1 = ["work", "school", "gym"]
    let pickerData2 = ["work", "school", "gym"]
    let my_pickerView = UIPickerView()
    var current_arr : [String] = []
    var active_textFiled : UITextField!
    var names: [AnyObject] = []
    
    // Starting of buttons and outlets
    @IBOutlet weak var sunday: BEMCheckBox!
    @IBOutlet weak var monday: BEMCheckBox!
    @IBOutlet weak var tuesday: BEMCheckBox!
    @IBOutlet weak var wednesday: BEMCheckBox!
    @IBOutlet weak var thursday: BEMCheckBox!
    @IBOutlet weak var friday: BEMCheckBox!
    @IBOutlet weak var saturday: BEMCheckBox!
    
   
    
    
    //labels for arrive and depart time
    @IBOutlet weak var arrivaltime1: UITextField!
    @IBOutlet weak var arrivaltime2: UITextField!
    @IBOutlet weak var departtime1: UITextField!
    @IBOutlet weak var departtime2: UITextField!
    

    // label that will allow the driver to save the name of a route
    @IBOutlet weak var routeName: UITextField!
    @IBOutlet weak var placeButton1: UITextField!
    @IBOutlet weak var placeButton2: UITextField!
   
    
    
    //label press action that brings up the time picker for arrival
    @IBAction func arrivalpress1(_ sender: UITextField) {
        createDatePicker1()
    }
    
    @IBAction func arrivalpress2(_ sender: UITextField) {
        createDatePicker3()
    }
    
    //label press action that brings up the time picker for depart
    @IBAction func departpress1(_ sender: UITextField) {
        createDatePicker2()
    }
    @IBAction func departpress2(_ sender: UITextField) {
        createDatePicker4()
    }
    
    //switch for deciding if the user is going to be a driver or no
    @IBOutlet weak var driverSetting: UISwitch!
    
    
    // when this save buttons is pressed, all information will then be transfered to the database
    @IBAction func actionSubmit(_ sender : Any)
    {
        var actionItem : String=String()
        var actionTitle : String=String()
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)  // default action to exit out of native alerts.
        
        dump(options)
        if ((placeButton1.text?.isEmpty)! || (placeButton2.text?.isEmpty)! || (arrivaltime1.text?.isEmpty)! || (departtime1.text?.isEmpty)! || (arrivaltime2.text?.isEmpty)! || (departtime2.text?.isEmpty)! || (routeName.text?.isEmpty)!)  // error handling for if all fields were filled  out.
        {
            actionTitle = "Error!"
            actionItem = "You have not entered all required information."
            
            // Activate UIAlertController to display error
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(exitAction)
            self.present(alert, animated: true, completion: nil)  // present error alert.
        }
        else {
            
            print(options.joined(separator: ", "))
            let driver = self.driverSetting.isOn
            let userID = Auth.auth().currentUser!.uid
//            let routeInfo = ["userID": userID, "Leaving from": placeButton1.text! as Any, "Going to": placeButton2.text! as Any,  "departureTime": departtime1.text! as Any, "arrivalTime" : arrivaltime1.text! as Any, "Days" :  options, "Longitudes": longitudeArray, "Latitudes": latitudeArray, "Driver": driver, "Name": self.routeName.text! as Any] as [String : Any]
            let routeInfo = ["userID": userID, "departureTime": departtime2.text! as Any, "arrivalTime" : arrivaltime2.text! as Any, "Days" :  options, "Longitudes": longitudeArray, "Latitudes": latitudeArray, "Driver": driver, "Name": self.routeName.text! as Any, "startAddress": self.placeButton1.text! as Any, "endAddress": self.placeButton2.text! as Any] as [String : Any]
            print (routeInfo)
            addRoute(routeInfo: routeInfo)
            actionTitle = "Success"
            actionItem = "Your route information has been saved"
            
            // Activate UIAlertController to display error
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(exitAction)
            self.present(alert, animated: true, completion: nil)
            //  print(arrivaltime.text)
            // print(departtime.text)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sunday.delegate = self
        monday.delegate = self
        tuesday.delegate = self
        wednesday.delegate = self
        thursday.delegate = self
        friday.delegate = self
        saturday.delegate = self
        placeButton1.delegate = self
        placeButton2.delegate = self
        my_pickerView.delegate = self
        my_pickerView.dataSource = self
        placeButton1.inputView = my_pickerView
        placeButton2.inputView = my_pickerView
        create_toolbar()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return current_arr.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return current_arr[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print ("Selected item is", current_arr[row])
        active_textFiled.text = current_arr[row]
    }
    func create_toolbar()
    {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolbar.setItems([doneButton , spaceButton, cancelButton], animated: false)
        
        placeButton1.inputAccessoryView = toolbar
        placeButton2.inputAccessoryView = toolbar
    }
    @objc func doneClick(){
        active_textFiled.resignFirstResponder()
    }
    @objc func cancelClick(){
        active_textFiled.text = ""
        active_textFiled.resignFirstResponder()
        
    }
    func createDatePicker1() {
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed1))
        toolbar.setItems([done], animated: false)
        
        arrivaltime1.inputAccessoryView = toolbar
        arrivaltime1.inputView = picker
        
        // format picker for date
        picker.datePickerMode = .time
    }
    @objc func donePressed1() {
        // format time using dateformatter
        let formatter = DateFormatter()
        // takes date off of the picker
        formatter.dateStyle = .none
        // allows for only HH:MM and am or pm
        formatter.timeStyle = .short
        // formatting the time into a string
        let dateString = formatter.string(from: picker.date)
        arrivaltime1.text = "\(dateString)"
        //converting time to 24hr format
        formatter.dateFormat = "HH:mm"
        let arrivetime124 = formatter.string(from: picker.date)
        print(arrivetime124)
        self.view.endEditing(true)
    }
    
    func createDatePicker2() {
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar picker
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed2))
        toolbar.setItems([done], animated: false)
        
        departtime1.inputAccessoryView = toolbar
        departtime1.inputView = picker
        
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
        departtime1.text = "\(dateString)"
        //converting time to 24hr format
        formatter.dateFormat = "HH:mm"
        let departtime124 = formatter.string(from: picker.date)
        print(departtime124)
        
        self.view.endEditing(true)
    }
    
    func createDatePicker3() {
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed3))
        toolbar.setItems([done], animated: false)
        
        arrivaltime2.inputAccessoryView = toolbar
        arrivaltime2.inputView = picker
        
        // format picker for date
        picker.datePickerMode = .time
    }
    @objc func donePressed3() {
        // format time using dateformatter
        let formatter = DateFormatter()
        // takes date off of the picker
        formatter.dateStyle = .none
        // allows for only HH:MM and am or pm
        formatter.timeStyle = .short
        // formatting the time into a string
        let dateString = formatter.string(from: picker.date)
        arrivaltime2.text = "\(dateString)"
        //converting time to 24hr format
        formatter.dateFormat = "HH:mm"
        let arrivaltime224 = formatter.string(from: picker.date)
        print(arrivaltime224)
        self.view.endEditing(true)
    }
    
    func createDatePicker4() {
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed4))
        toolbar.setItems([done], animated: false)
        
        departtime2.inputAccessoryView = toolbar
        departtime2.inputView = picker
        
        // format picker for date
        picker.datePickerMode = .time
    }
    @objc func donePressed4() {
        // format time using dateformatter
        let formatter = DateFormatter()
        // takes date off of the picker
        formatter.dateStyle = .none
        // allows for only HH:MM and am or pm
        formatter.timeStyle = .short
        // formatting the time into a string
        let dateString = formatter.string(from: picker.date)
        departtime2.text = "\(dateString)"
        //converting time to 24hr format
        formatter.dateFormat = "HH:mm"
        let departtime224 = formatter.string(from: picker.date)
        print(departtime224)
        self.view.endEditing(true)
    }
    
    //start switch statement that will check if each box is checked, then print out names of checked days
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
    
    //function that will analyze each checkbox to decide if it is checked or not, whenever save is pressed. It goes through of of the switch cases and whichever ones are on, it adds that day to the array
    func addRemoveOption(forState : Bool , option : String)
    {
        switch forState
        {
        //if box is checked add that day to the array
        case true:
            
            options += [option]
            dump(options)
        //if box is not checked, or checked then unchecked, remove it from the array
        case false:
            if let index = options.index(of: option)
            {
                options.remove(at: index)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Keyboard handling
    // Begin editing within text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
       //moveScrollView(textField, distance: dist, up: true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        active_textFiled = textField
        
        switch textField {
        case placeButton1:
            current_arr = pickerData1
        case placeButton2:
            current_arr = pickerData2
        default:
            print("Default")
        }
        my_pickerView.reloadAllComponents()
        return true
    }
    
    // End editing within text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        //moveScrollView(textField, distance: dist, up: false)
    }
    
    // Hide keyboard if return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    // Move scroll view
    func moveScrollView(_ textField: UITextField, distance: Int, up: Bool) {
        let movement: CGFloat = CGFloat(up ? distance: -distance)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
    }
}

func addRoute(routeInfo: Dictionary<String, Any>)
{
    let routeURL = URL(string: "http://localhost:3000/routes/")!
    var request = URLRequest(url: routeURL)
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
        }
        
        }.resume()
}
