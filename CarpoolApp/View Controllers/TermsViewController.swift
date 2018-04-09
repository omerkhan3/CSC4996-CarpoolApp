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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
