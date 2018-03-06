//
//  PaymentsViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/5/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Braintree
import BraintreeDropIn
import Firebase
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth

class PaymentsViewController: UIViewController {

    let tokenizationKey =  "sandbox_vtqbvdrz_kjjqnn2gj7vbds9g"
    
    @IBAction func newPaymentMethod(_ sender: Any) {
        showDropIn(clientTokenOrTokenizationKey: self.tokenizationKey)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Shows the braintree Drop-In UI
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request = BTDropInRequest()
        let dropIn = BTDropInController(authorization: self.tokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("Error.")
            }
            else if (result?.isCancelled == true) {
                print("Cancelled.")
            }
            else if let paymentResult = result {
                let selectedPaymentMethod = paymentResult.paymentMethod?.nonce
                self.postNonceToServer(paymentMethodNonce: selectedPaymentMethod!)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    //Method to send unique payment nonce to server for transaction
    func postNonceToServer(paymentMethodNonce: String) {
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print (error.localizedDescription)
                return;
            }
            let userToken = idToken!
            //URL endpoint of our local node server
            let paymentURL = URL(string: "http://141.217.48.15:3000/payment/")!
            var request = URLRequest(url: paymentURL)
            //payment_method_nonce is the field that the server will be looking for to receive the nonce
            request.httpBody = "payment_method_nonce=\(paymentMethodNonce)&idToken=\(userToken)".data(using: String.Encoding.utf8)
            //POST method
            request.httpMethod = "POST"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                //Error handling response
                if (error != nil){
                    print ("An error has occured.")
                }
                else{
                    print ("Success!")
                }
                }.resume()
        }
    }
}

class TableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TableViewCell"
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
}

