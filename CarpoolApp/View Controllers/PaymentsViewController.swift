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

class PaymentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var clientToken: String = ""
    
    //array of payments
    var recentPaymentsArray = [RecentPayments]()
    var recentPayments = RecentPayments()
    
    @IBAction func newPaymentMethod(_ sender: Any) {
        showDropIn(clientTokenOrTokenizationKey: self.clientToken)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        makeRequest() { clientToken in
            self.clientToken = clientToken
        }
        
        /*getPayments {
            self.tableView.reloadData()
            if self.recentPaymentsArray.count == 0 {
                // No payments alert
                let actionTitle = "Uh oh.."
                let actionItem = "You have no payments!"
                
                // Activate UIAlertController to display confirmation
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                }))
                self.present(alert, animated: true, completion: nil)
            }*/
        }
        
        //self.tableView.delegate = self
        //self.tableView.dataSource = self
    //}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recentPayments = recentPaymentsArray[indexPath.row]
        print(recentPayments)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "TableViewCell")
        
        return cell
    }
    
    // set number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentPaymentsArray.count
    }
    
    // Download payments JSON and decode into an array
    /*func getPayments(completed: @escaping () -> ()) {
        // get userID
        let userID = Auth.auth().currentUser?.uid
        var viewMatchComponents = URLComponents(string: "http://localhost:3000/payment/Payments")!
        viewMatchComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
        var request = URLRequest(url: viewMatchComponents.url!)  // Pass Parameter in URL
        print (viewMatchComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            } else {
                guard let data = data else { return }
                do {
                    // decode JSON into recentPayments[] array type
                    self.recentPaymentsArray = try JSONDecoder().decode([RecentPayments].self, from: data)
                    print(self.recentPaymentsArray)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch let jsnErr {
                    print(jsnErr)
                }
            }
            }.resume()
    }*/
    
    
    func makeRequest(completion: @escaping (String) -> Void) {
        let clientTokenURL = URL(string: "http://localhost:3000/payment/client_token")!
        var clientTokenRequest = URLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest) { (data, response, error) -> Void in
            //Error handling response
            guard let responseData = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            print ("Success!")
            let clientToken = String(data: responseData, encoding: .utf8) ?? ""
            completion(clientToken)
            }.resume()
    }
    
    func fetchExistingPaymentMethod(clientToken: String) {
        BTDropInResult.fetch(forAuthorization: clientToken, handler: { (result, error) in
            if(error != nil) {
                print("ERROR")
            } else if let paymentResult = result {
                let selectedPaymentMethod = paymentResult.paymentMethod?.nonce
                self.postNonceToServer(paymentMethodNonce: selectedPaymentMethod!)
                print(paymentResult)
            }
        })
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
                print(paymentResult)
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
            //let userToken = idToken!
            //URL endpoint of our local node server
            let paymentURL = URL(string: "http://localhost:3000/payment/checkout")!
            var request = URLRequest(url: paymentURL)
            //payment_method_nonce is the field that the server will be looking for to receive the nonce
            request.httpBody = "payment_method_nonce=\(paymentMethodNonce)".data(using: String.Encoding.utf8)
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

