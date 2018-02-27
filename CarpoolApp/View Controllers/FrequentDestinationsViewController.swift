//
//  Frequent Destinations.swift
//  CarpoolApp
//
//  Created by Matt on 2/17/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import BEMCheckBox

class FrequentDestinationsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, BEMCheckBoxDelegate   {


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
    

    let picker = UIDatePicker()
    
    let pickerData = ["work", "school", "gym"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //pickerView.isHidden = true
       // pickerView.delegate = self
       // pickerView.dataSource = self
        placePicker.isHidden = true
        placePicker.delegate = self
        placePicker.dataSource = self
        sunday.delegate = self
        monday.delegate = self
        tuesday.delegate = self
        wednesday.delegate = self
        thursday.delegate = self
        friday.delegate = self
        saturday.delegate = self
       
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
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed2))
        toolbar.setItems([done], animated: false)
        
        departtime.inputAccessoryView = toolbar
        departtime.inputView = picker
        
        // format picker for date
        picker.datePickerMode = .time
    }
    
    @objc func donePressed2() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let dateString = formatter.string(from: picker.date)
        
        departtime.text = "\(dateString)"
        self.view.endEditing(true)
        
    }
    
    
    @IBAction func placePress(_ sender: UIButton) {
        if placePicker.isHidden{
            placePicker.isHidden = false
        }    }
        

    
   //  returns the number of 'columns' to display.
    
    public func numberOfComponents(in placePicker: UIPickerView) -> Int {
        return 1

    }
    // returns the # of rows in each component..

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
             placeButton.setTitle(pickerData[row], for: .normal)
            placePicker.isHidden = true
            
        
    }
    
   
    
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
        case false:
            if let index = options.index(of: option)
            {
                options.remove(at: index)
            }
            
        }
    }
    @IBAction func actionSubmit(_ sender : Any)
    {
        print(options.joined(separator: "&"))
        print(arrivaltime.text)
        print(departtime.text)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
