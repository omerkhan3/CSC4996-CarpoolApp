//
//  PaymentsViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/2/18.
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
    
    //let tokenizationKey =  "sandbox_vtqbvdrz_kjjqnn2gj7vbds9g"
    let clientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJhMTNhMTkwNzdhZjFhZmNlMGM5ZGQ1NWMzNGRhYzc4ZmI4MWRhMTM3Y2ZiODc0M2FkNDdhNjZkZGVkMTgyOTMwfGNyZWF0ZWRfYXQ9MjAxOC0wMy0xMlQwMzozODoxMy42NDUyOTc3NjYrMDAwMFx1MDAyNm1lcmNoYW50X2lkPTM0OHBrOWNnZjNiZ3l3MmJcdTAwMjZwdWJsaWNfa2V5PTJuMjQ3ZHY4OWJxOXZtcHIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzLzM0OHBrOWNnZjNiZ3l3MmIvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tLzM0OHBrOWNnZjNiZ3l3MmIifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJtZXJjaGFudEFjY291bnRJZCI6ImFjbWV3aWRnZXRzbHRkc2FuZGJveCIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJtZXJjaGFudElkIjoiMzQ4cGs5Y2dmM2JneXcyYiIsInZlbm1vIjoib2ZmIn0="
    
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
        let clientTokenURL = NSURL(string: "http://localhost:3000/payment/")!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            //Error handling response
            if (error != nil){
                print ("An error has occured.")
            }
            else{
                print ("Success!")
            }
            //let clientToken = String(data: data!, encoding: String.Encoding.utf8)
            }.resume()
    }
    
    //Shows the braintree Drop-In UI
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request = BTDropInRequest()
        let dropIn = BTDropInController(authorization: self.clientToken, request: request)
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

//Need this new class when you are repeating content in a table view cell, error when no new class
class TableViewCell: UITableViewController {
    static let reuseIdentifier = "TableViewCell"
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var myPayments = [Payments]()
    struct Payments: Decodable {
        let amount: String
        let time: String
        let contact: String
        
        init(json: [String: Any]) {
            amount = json["Amount"] as? String ?? ""
            contact = json["userID"] as? String ?? ""
            time = json["Time"] as? String ?? ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paymentInfo {
            self.tableView.reloadData()
            if self.myPayments.count == 0 {
                let actionTitle = "Uh oh.."
                let actionItem = "You have no recent payments!"
                
                // Activate UIAlertController to display confirmation
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func paymentInfo(userID: String)
    {
        var viewProfileComponents = URLComponents(string: "http://localhost:3000/paymentHistory")!
        viewProfileComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewProfileComponents.url!)  // Pass Parameter in URL
        print (viewProfileComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            }
            else if let data = data {
                let userInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                while let data = userInfoString.data(using: String.Encoding.utf8.rawValue) {
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        if let userInfo = json
                        {
                            DispatchQueue.main.async {
                                self.contactLabel.text = (userInfo["userID"] as! String)
                                self.dateLabel.text = (userInfo["Date"] as! String)
                                self.amountLabel.text = (userInfo["Amount"] as! String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
        }
    }*/
    
    //Decoding payments
    func paymentInfo(completed: @escaping () -> ()) {
        let userID = Auth.auth().currentUser?.uid
        var viewPaymentComponents = URLComponents(string: "http://localhost:3000/paymentHistory")!
        viewPaymentComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
        var request = URLRequest(url: viewPaymentComponents.url!)  // Pass Parameter in URL
        print (viewPaymentComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            } else {
                guard let data = data else {return}
                do {
                    self.myPayments = try JSONDecoder().decode([Payments].self, from: data)
                    print(self.myPayments)
                    DispatchQueue.main.async {
                        self.amountLabel.text = self.myPayments[0].amount
                        self.contactLabel.text = self.myPayments[0].contact
                        self.dateLabel.text = self.myPayments[0].time
                        completed()
                    }
                }catch let jsnErr {
                    print(jsnErr)
                }
            }
        }.resume()
    }
}
