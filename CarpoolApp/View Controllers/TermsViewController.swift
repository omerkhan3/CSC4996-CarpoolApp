//
//  TermsViewController.swift
//  CarpoolApp
//
//  Created by Matt on 4/9/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import WebKit
class TermsViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = Bundle.main.path(forResource: "Introduction", ofType: "pdf")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
        
        webView.load(request)
        
    }

}
