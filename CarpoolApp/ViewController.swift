//
//  ViewController.swift
//  CarpoolApp
//
//  Created by Omer Khan on 1/27/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import MapKit
import Braintree
import Alamofire

class ViewController: UIViewController
{
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var labelMessage: UILabel!
    
    @IBAction func registerButton(_ sender: UIButton)//login information screen
    {
        let email = emailField.text
        let password = passwordField.text
        
        Auth.auth().createUser(withEmail: email!, password: password!, completion:
        { (user: User?, error) in
            if error == nil
            {
                self.labelMessage.text = "Registration Successful!"
            }
            else
            {
                self.labelMessage.text = "User Already Exists, Please Try Again."
            }
        })
    }
    
    @IBOutlet weak var paymentButton: UIButton!
    var braintreeClient : BTAPIClient!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        FirebaseApp.configure()
        
        paymentButton.isEnabled = false
        
        Alamofire.request( "http://localhost:3000/token").responseJSON
        {
            response in
            if response.result.value != nil
            {
                let clientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJjZGM0YmJiZTM2OGVlMzkxYjQ3ZWE4YjhhNzk0Mjk5YmZkNjI1ZGYyMWE3Mjg2N2IzMjU5YjVjZDI1NzlmNTUxfGNyZWF0ZWRfYXQ9MjAxOC0wMi0wNFQwMzozMjo1NS45NDgzMDc3MDUrMDAwMFx1MDAyNm1lcmNoYW50X2lkPTM0OHBrOWNnZjNiZ3l3MmJcdTAwMjZwdWJsaWNfa2V5PTJuMjQ3ZHY4OWJxOXZtcHIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzLzM0OHBrOWNnZjNiZ3l3MmIvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tLzM0OHBrOWNnZjNiZ3l3MmIifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJtZXJjaGFudEFjY291bnRJZCI6ImFjbWV3aWRnZXRzbHRkc2FuZGJveCIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJtZXJjaGFudElkIjoiMzQ4cGs5Y2dmM2JneXcyYiIsInZlbm1vIjoib2ZmIn0="
                self.paymentButton.isEnabled = true
                self.braintreeClient = BTAPIClient(authorization: clientToken)!
            }
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    @IBAction func letPay(_ sender: UIButton)
    {
        let dropInViewController = BTDropInViewController(apiClient: braintreeClient)
        dropInViewController.delegate = self as? BTDropInViewControllerDelegate
        
        dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: Selector(("userCancelledPayment")))
        
        let navigationController = UINavigationController(rootViewController: dropInViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func userCancelledPayment()
    {
        dismiss(animated: true, completion: nil)
    }
    
    func dropInViewController (viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce)
    {
        postNonceToServer(paymentMethodNonce: paymentMethodNonce.nonce)
        dismiss(animated: true, completion: nil)
    }
    
    func dropInViewControllerDidCancel(viewController: BTDropInViewController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func postNonceToServer (paymentMethodNonce: String)
    {
        let paymentURL = URL(string:"http://localhost:3000/payment")
        var request = URLRequest(url: paymentURL!)
        request.httpBody = "payment_method_nonce=\(paymentMethodNonce)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request)
        {
          (data, response, error) -> Void in
         }.resume()
    }
}


