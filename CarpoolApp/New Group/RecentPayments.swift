//
//  RecentPayments.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/28/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct RecentPayments: Decodable {
    let userID: String
    let Time: String
    let Amount: String
    
    init(json: [String: Any]) {
        userID = json["userID"] as? String ?? ""
        Time = json["Time"] as? String ?? ""
        Amount = json["Amount"] as? String ?? ""
    }
    
    init() {
        userID = ""
        Time = ""
        Amount = ""
    }
}
