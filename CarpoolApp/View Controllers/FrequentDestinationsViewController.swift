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
    
    
   
    
    
    
    let pickerData = ["work", "school", "gym"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        pickerView.isHidden = true
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

    @IBAction func placePress(_ sender: UIButton) {
        if placePicker.isHidden{
            placePicker.isHidden = false
        }    }
    @IBAction func arrivalPress(_ sender: UIButton) {
        
        if pickerView.isHidden{
            pickerView.isHidden = false
        }
    }
    
    @IBAction func departurePress(_ sender: UIButton) {
        
        if pickerView.isHidden{
            pickerView.isHidden = false
        }
        
    }
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
