//
//  Frequent Destinations.swift
//  CarpoolApp
//
//  Created by Matt on 2/17/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit


class FrequentDestinationsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate   {

   
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var arrivalButton: UIButton!
    @IBOutlet weak var departureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.isHidden = true
       
    }

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
    // returns the number of 'columns' to display.
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
        
    }
    // returns the # of rows in each component..
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
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
