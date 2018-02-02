//
//  paymentViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 2/2/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//
//SDK tokenizes all credit card data into a nonce which takes care of sensitive data without the merchant having to deal with compliance issues so not actually touching the credit card details (Nonce payment method or charge)

import Foundation
import UIKit
import BraintreeDropIn
import Braintree
import AlamoFire         //Use alamofire to make request for token

class ViewController: UIViewController,
    BTDropInViewControllerDelegate
{
    @IBOutlet weak var payBtn: UIButton!
    var braintreeClient: BTAPIClient?        //Create client
    override func viewDidLoad()
    {
        super.viewDidLoad()       //View controller starts
        payBtn.enabled = false    //Disable here because we don't want user to click on it before the app is able to authorize itself against braintree
        
        Alamofire.request(.GET, "http://localhost:8000/get_token").responseJSON    //Making request to local server to get the token
            {
                response in if let JSON = response.result.value     //Response will come in as client token
                {
                    let clientToken = JSON["clientToken"] as! String;
                    self.payBtn.enabled = true;
                    self.braintreeClient = BTAPIClient(authorization: clientToken)     //Setup the braintree client and initialize it with the token
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    @IBAction func letMePay ()
    {
        let dropInViewController = BTDropInViewController (APIClient: braintreeClient!)   //dropinviewcontroller is from client SDK, embeds itself into your current UI, you can declare it as viewcontroller and push it onto UI stack
        dropInViewController.delegate = self     //Set delegate to self so you can get callbacks
        
        dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(UIBarButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "userDidCancelPayment")
        
        let navigationController = UINavigationController(rootViewController: dropInViewController)
        presentViewController(navigationController, animated: true, completion: nil)   //Presenting UI controller
    }
    
    
    //As part of delegate protocol, implementing two functions where one is where user goes through the whole flow and you get Nonce back so the payment was successful and the other function is if the user cancels the payment
    func userDidCancelPayment()
    {
        dismissViewControllerAnimated(true, completion: nil)   //If user cancels payment, dismiss the controller and go back to the application
    }
    
    func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenizationpaymentMethodNonce: BTPaymentMethodNonce)
    {
        postNonceToServer(paymentMethodNonce.nonce)       //If it succeeds, the SDK will pass back a Nonce which is a string that represents the payment method, postNonceToServer is posting it to server and the server will take the string and create a transaction
        dismissViewControllerAnimated(true, completion: nil)     //Dismiss the controller
    }
    
    func dropInViewControllerDidCancel(viewController:BTDropInViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
}
