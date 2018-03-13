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

    var braintreeClient: BTAPIClient?
    //let tokenizationKey =  "sandbox_vtqbvdrz_kjjqnn2gj7vbds9g"
    let clientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJhYTBlYzBjMzI3MjEzM2UzYTQ5ZmFiMDJjNzljYzc5YjBmM2Y5NTI2NTI4OTQ0ODFkMTM3N2E4NWNlNGU0YTdkfGNyZWF0ZWRfYXQ9MjAxOC0wMy0xM1QwNDo1ODo1My42MjAzMTExMzUrMDAwMFx1MDAyNm1lcmNoYW50X2lkPTM0OHBrOWNnZjNiZ3l3MmJcdTAwMjZwdWJsaWNfa2V5PTJuMjQ3ZHY4OWJxOXZtcHIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzLzM0OHBrOWNnZjNiZ3l3MmIvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tLzM0OHBrOWNnZjNiZ3l3MmIifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJtZXJjaGFudEFjY291bnRJZCI6ImFjbWV3aWRnZXRzbHRkc2FuZGJveCIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJtZXJjaGFudElkIjoiMzQ4cGs5Y2dmM2JneXcyYiIsInZlbm1vIjoib2ZmIn0="
    
    
    @IBAction func newPaymentMethod(_ sender: Any) {
        showDropIn(clientTokenOrTokenizationKey: self.clientToken)
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
    
    func fetchClientToken() {
        let clientTokenURL = URL(string: "http://localhost:3000/payment/")!
        var clientTokenRequest = URLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            //Error handling response
            if (error != nil){
                print ("An error has occured.")
            }
            else{
                print ("Success!")
            }
            let clientToken = String(data: data!, encoding: String.Encoding.utf8)!
            self.braintreeClient = BTAPIClient(authorization: clientToken)
            print("Client Token: \(clientToken)")
            }.resume()
    }
    
    //Shows the braintree Drop-In UI
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request = BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
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
            let paymentURL = URL(string: "http://localhost:3000/payment/")!
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

