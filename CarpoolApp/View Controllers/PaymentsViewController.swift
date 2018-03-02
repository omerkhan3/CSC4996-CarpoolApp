//
//  PaymentsViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/2/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit

class PaymentsViewController: UIViewController {

    
    @IBAction func newPaymentMethod(_ sender: Any) {
    }
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//Need this new class when you are repeating content in a table view cell, error when no new class
class TableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TableViewCell"
    
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
}
