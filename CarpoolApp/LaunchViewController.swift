//
//  LaunchViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 1/31/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    @IBOutlet weak var logo: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateLogo() // Animation function
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // delay to allow for animation
        let time = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: time){
            self.performSegue(withIdentifier: "toLogin", sender: self) // manually perform segue
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateLogo(){
        UIView.animate(withDuration: 2, animations: {
            self.logo.transform = CGAffineTransform(scaleX: 2, y:2) // Zoom effect
            self.logo.alpha = 0.0 // Fade effect
        })
    }
    
}
