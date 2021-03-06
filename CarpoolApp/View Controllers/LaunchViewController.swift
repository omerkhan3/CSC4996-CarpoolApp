//
//  LaunchViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 1/31/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    @IBOutlet weak var logo: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateLogo() // Animation function
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // delay to allow for animation
        let time = DispatchTime.now() + 2.5
        
        // Go to onboarding
        if firstTime == "firstTime" {
            DispatchQueue.main.asyncAfter(deadline: time){
                self.performSegue(withIdentifier: "showOnboarding", sender: self) // manually perform segue
            }
            // Go to login
        } else {
        DispatchQueue.main.asyncAfter(deadline: time){
            self.performSegue(withIdentifier: "showLogin", sender: self) // manually perform segue
                }
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func animateLogo(){
        UIView.animate(withDuration: 2, animations: {
            self.logo.transform = CGAffineTransform(scaleX: 2, y:2) // Zoom effect
            self.logo.alpha = 0.0 // Fade effect
        })
    }
}
