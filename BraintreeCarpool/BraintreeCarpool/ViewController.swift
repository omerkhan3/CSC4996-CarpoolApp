//
//  ViewController.swift
//  BraintreeCarpool
//
//  Created by Omer  Khan on 2/3/18.
//  Copyright © 2018 Omer  Khan. All rights reserved.
//

import UIKit
import Braintree
import BraintreeDropIn

class ViewController: UIViewController {

    @IBOutlet weak var paymentButton: UIButton!
    let tokenizationKey = "sandbox_vtqbvdrz_kjjqnn2gj7vbds9g"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func letPay(_ sender: UIButton) {
        showDropIn(clientTokenOrTokenizationKey: self.tokenizationKey)
    }


        func showDropIn(clientTokenOrTokenizationKey: String) {
            let request =  BTDropInRequest()
            let dropIn = BTDropInController(authorization: self.tokenizationKey, request: request)
            { (controller, result, error) in
                if (error != nil) {
                    print("Error.")
                } else if (result?.isCancelled == true) {
                    print("Cancelled.")
                    
                } else if let result = result {
                    let selectedPaymentMethod = result.paymentMethod?.nonce
                    self.postNonceToServer(paymentMethodNonce: selectedPaymentMethod!)
                }
                controller.dismiss(animated: true, completion: nil)
            }
            self.present(dropIn!, animated: true, completion: nil)
        }
    
    
    
        func postNonceToServer(paymentMethodNonce: String) {
            let paymentURL = URL(string: "http://localhost:3000/checkout")!
            var request = URLRequest(url: paymentURL)
            request.httpBody = "payment_method_nonce=\(paymentMethodNonce)".data(using: String.Encoding.utf8)
            request.httpMethod = "POST"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                if (error != nil){
                    print ("An error has occured.")
                }
                else{
                    print ("Success!")
                }
                
                }.resume()
        }
    
}


