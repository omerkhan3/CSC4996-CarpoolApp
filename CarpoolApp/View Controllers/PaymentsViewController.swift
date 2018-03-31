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

class PaymentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Class variables
    var clientToken: String = ""
    var recentPaymentsArray = [RecentPayments]()
    var recentPayments = RecentPayments()
    var paymentsArray = [Payments]()
    var payments = Payments()
    let userID = Auth.auth().currentUser?.uid
    
    //Outlets
    @IBAction func newPaymentMethod(_ sender: Any) {
        showDropIn(clientTokenOrTokenizationKey: self.clientToken)
    }
    @IBOutlet weak var recentPaymentsTable: UITableView!
    @IBOutlet weak var noPaymentsLabel: UILabel!
    @IBOutlet weak var paymentsTable: UITableView!
    @IBOutlet weak var noPaymentMethods: UILabel!
    
    @IBAction func showPaymentMethod(_ sender: Any) {
        fetchExistingPaymentMethod(clientToken: clientToken)
        postNonceToServer(paymentMethodNonce: clientToken)
        paymentsTable.isHidden = false
        
        getPaymentMethods {
            self.paymentsTable.reloadData()
            
            if self.paymentsArray.count == 0 {
                self.noPaymentMethods.isHidden = false
            } else {
                self.noPaymentMethods.isHidden = true
            }
        }
        self.paymentsTable.delegate = self
        self.paymentsTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recentPaymentsTable.reloadData()
        
        getRecentPayments {
            self.recentPaymentsTable.reloadData()
            
            //Show or hide no recent payments alert
            if self.recentPaymentsArray.count == 0 {
                // No recent payments
                self.noPaymentsLabel.isHidden = false
            } else {
                self.noPaymentsLabel.isHidden = true
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.recentPaymentsTable {
            recentPayments = recentPaymentsArray[indexPath.row]
            print(recentPayments)
        }
        if tableView == self.paymentsTable {
            payments = paymentsArray[indexPath.row]
            print(payments)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //guard let cell = tableView.dequeueReusableCell(withIdentifier: recentPaymentsCell.reuseIdentifier, for: indexPath) as? recentPaymentsCell else { fatalError("Unable to dequeue a recentPaymentsCell") }
        
        //Create date formatter and reformat date
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        //let date = dateFormatter.date(from: recentPaymentsArray[indexPath.row].Time)!
        //dateFormatter.dateFormat = "MM-dd-YYYY"
        //let dateString = dateFormatter.string(from: date)
        
        //var amountFormatter: NumberFormatter = {
        //    let formatter = NumberFormatter()
          //  formatter.numberStyle = .currency
            //return formatter
        //}()
        var cell:UITableViewCell?
        
        if tableView == self.recentPaymentsTable {
            let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "recentPayments")
            cell.textLabel?.text = recentPaymentsArray[indexPath.row].Contact.uppercased()
            cell.detailTextLabel?.text = recentPaymentsArray[indexPath.row].Time.uppercased()
            //cell.detailTextLabel?.text = dateString
        }
        if tableView == self.paymentsTable {
            let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "viewPayments")
            cell.textLabel?.text = paymentsArray[indexPath.row].customerToken.uppercased()
            //cell.detailTextLabel?.text = paymentsArray[indexPath.row].customerToken.uppercased()
        }
        
        return cell!
    }
    
    // Set number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?
        
        if tableView == self.recentPaymentsTable {
            return recentPaymentsArray.count
        }
        if tableView == self.paymentsTable {
            return paymentsArray.count
        }
        return count!
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
    
    func getPaymentMethods(completed: @escaping () -> ()) {
        var viewPaymentMethodComponents = URLComponents(string: "http://localhost:3000/payment/getPaymentMethod")!
        viewPaymentMethodComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
        var request = URLRequest(url: viewPaymentMethodComponents.url!)
        print (viewPaymentMethodComponents.url!)
        
        // GET Method
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){
                print (error as Any)
            } else {
                guard let data = data else { return }
                do {
                    // Decode JSON
                    self.paymentsArray = try JSONDecoder().decode([Payments].self, from: data)
                    print (self.paymentsArray)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch let jsnERR {
                    print(jsnERR)
                }
            }
            }.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
            let userToken = idToken!
            //URL endpoint of our local node server
            let paymentURL = URL(string: "http://localhost:3000/payment/checkout")!
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

//class recentPaymentsCell: UITableViewCell {
  //  static let reuseIdentifier = "recentPayments"
    //@IBOutlet weak var dateLabel: UILabel!
    //@IBOutlet weak var amountLabel: UILabel!
    //@IBOutlet weak var contactLabel: UILabel!
    
//}

