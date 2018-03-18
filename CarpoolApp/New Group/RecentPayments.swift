//
//  RecentPayments.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/17/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct RecentPayments: Decodable {
    let Contact: String
    let Date: String
    let Amount: String
    
    init(json: [String: Any]) {
        Contact = json["userID"] as? String ?? ""
        Date = json["Time"] as? String ?? ""
        Amount = json["Amount"] as? String ?? ""
    }
    
    init() {
        Contact = ""
        Date = ""
        Amount = ""
    }
}
