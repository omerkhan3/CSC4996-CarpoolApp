//
//  Payments.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/30/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit

struct Payments: Decodable {
    let customerToken: String
    
    init(json: [String: Any]) {
        customerToken = json["Time"] as? String ?? ""
    }
    
    init() {
        customerToken = ""
    }
}
