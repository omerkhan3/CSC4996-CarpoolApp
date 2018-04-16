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

class recentPaymentsCell: UITableViewCell {
    static let reuseIdentifier = "recentPayments"
    @IBOutlet weak var driverFirstName: UILabel!
    @IBOutlet weak var Amount: UILabel!
    @IBOutlet weak var Time: UILabel!
}

class PaymentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Class variables
    var clientToken: String = ""
    var recentPaymentsArray = [RecentPayments]()
    var recentPaymentsDetail: RecentPayments?
    
    let userID = Auth.auth().currentUser?.uid
    let tokenizationKey =  "sandbox_vtqbvdrz_kjjqnn2gj7vbds9g" // this is the tokenization key needed to authenticate with Braintree sandbox.  Since this is just a sandbox account, we have hard-coded the key in, but for production this key would need to be hosted elsewhere.
    
    //Outlets
    @IBAction func newPaymentMethod(_ sender: Any) {
        if (self.clientToken == "")
        {
            showDropIn(clientTokenOrTokenizationKey: self.tokenizationKey)
            
        }
        else{
            showDropIn(clientTokenOrTokenizationKey: self.clientToken)
        }
    }
    
    @IBOutlet weak var recentPaymentsTable: UITableView!
    @IBOutlet weak var noPaymentsLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recentPaymentsTable.reloadData()
        
        getRecentPayments {
            self.recentPaymentsTable.reloadData()
            
            //Show or hide no recent payments alert
            if self.recentPaymentsArray.count == 0 {
                // No recent payments
                self.noPaymentsLabel.isHidden = false
                self.recentPaymentsTable.isHidden = true
            } else {
                self.noPaymentsLabel.isHidden = true
                self.recentPaymentsTable.isHidden = false
            }
        }
        
        self.recentPaymentsTable.delegate = self
        self.recentPaymentsTable.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeRequest() { clientToken in
            self.clientToken = clientToken
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentPayments", for: indexPath) as! recentPaymentsCell
        
        cell.driverFirstName.text = "Driver:  " + recentPaymentsArray[indexPath.row].firstName
        cell.Time?.text = "Date:  " + formatDate(date: recentPaymentsArray[indexPath.row].Time)
        cell.Amount.text = "$" + String(describing: Double(round(100 * recentPaymentsArray[indexPath.row].Amount)/100))
        
        return cell
    }
    
    // Set number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentPaymentsArray.count
    }
    
    // Query all recent payments from database and, decode and store into an array
    func getRecentPayments(completed: @escaping () -> ()) {
        var viewRecentPaymentsComponents = URLComponents(string: "http://localhost:3000/payment/recentPayments")!
        viewRecentPaymentsComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
        var request = URLRequest(url: viewRecentPaymentsComponents.url!)
        print (viewRecentPaymentsComponents.url!)
        
        // GET Method
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){
                print (error as Any)
            } else {
                guard let data = data else { return }
                do {
                    // Decode JSON
                    self.recentPaymentsArray = try JSONDecoder().decode([RecentPayments].self, from: data)
                    print (self.recentPaymentsArray)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch let jsnERR {
                    print(jsnERR)
                }
            }
            }.resume()
    }
    
    func makeRequest(completion: @escaping (String) -> Void) {
        var clientTokenComponents = URLComponents(string: "http://localhost:3000/payment/client_token")!
        clientTokenComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
        var clientTokenRequest = URLRequest(url: clientTokenComponents.url!)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            let userToken = idToken!
            //URL endpoint of our local node server
            let paymentURL = URL(string: "http://localhost:3000/payment/create")!
            var request = URLRequest(url: paymentURL)
            let paymentInfo = ["userID": self.userID as Any, "paymentMethodNonce": paymentMethodNonce as Any, "userToken":  userToken as Any] as [String : Any]
            let paymentJSON = try! JSONSerialization.data(withJSONObject: paymentInfo, options: .prettyPrinted)
            let paymentJSONInfo = NSString(data: paymentJSON, encoding: String.Encoding.utf8.rawValue)! as String
            //payment_method_nonce is the field that the server will be looking for to receive the nonce
            request.httpBody = "paymentInfo=\(paymentJSONInfo)".data(using: String.Encoding.utf8)
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
    
    func formatDate(date: String) -> String {
        // Create date formatter and reformat date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        print(date)
        let formattedDate = dateFormatter.date(from: date)!
        dateFormatter.dateFormat = "MM-dd-YYYY h:mm a"
        let dateString = dateFormatter.string(from: formattedDate)
        
        return dateString
    }
}
