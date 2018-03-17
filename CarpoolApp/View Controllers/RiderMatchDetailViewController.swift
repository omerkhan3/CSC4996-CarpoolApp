//
//  RiderMatchDetailViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/6/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import FirebaseAuth

class RiderMatchDetailViewController: UIViewController {
    
    var matchDetail: Match?

    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var time: UILabel!
    
    @IBAction func requestRide(_ sender: Any) {
        let actionTitle = "Ride Request"
        let actionItem = "Your ride request has been sent to the driver! You will be notified if your ride is confirmed."
        
        let userID = Auth.auth().currentUser!.uid
        let matchInfo = ["userID": userID, "matchID" : matchDetail?.matchID as Any, "requestType":  "riderRequest"] as [String : Any]
        
        riderRequest(matchInfo:  matchInfo)
        
        // Activate UIAlertController to display confirmation
        let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            //self.performSegue(withIdentifier: "showMatches2", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func riderRequest(matchInfo: Dictionary<String, Any>)
    {
        let requestURL = URL(string: "http://localhost:3000/matches/approval")!
        var request = URLRequest(url: requestURL)
        let requestJSON = try! JSONSerialization.data(withJSONObject: matchInfo, options: .prettyPrinted)
        let requestJSONInfo = NSString(data: requestJSON, encoding: String.Encoding.utf8.rawValue)! as String
        request.httpBody = "requestInfo=\(requestJSONInfo)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST" // POST method.
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print ("An error has occured.")
            }
            else{
                print ("Success!")
            }
            
            }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(matchDetail)
        self.driverName.text = matchDetail?.driverFirstName
        self.destination.text = matchDetail?.driverRouteName
        self.time.text = matchDetail?.driverArrival

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMapOverview" {
            if let mapViewController = segue.destination as? MapViewController {
                mapViewController.mapMatchDetail = matchDetail
            }
        }
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
