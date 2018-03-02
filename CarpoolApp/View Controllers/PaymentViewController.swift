//
//  PaymentViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/1/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
    
    @IBOutlet weak var paymentsTable: UITableView!
    @IBAction func newPayment(_ sender: Any) {
        
    }
    
    //This is for formatting the payment amounts in table view cells
    private var amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    //This is for formatting the dates in table view cells
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
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


//Need this new class for labels and cell or it will give an error for invalid use
class PaymentTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TableViewCell"
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
}



