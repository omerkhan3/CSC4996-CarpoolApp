//
//  User.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/5/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct Profile: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let biography: String
    let photo: String
    
    init(json: [String: Any]) {
        firstName = json["firstName"] as? String ?? ""
        lastName = json["lastName"] as? String ?? ""
        email = json["Email"] as? String ?? ""
        phone = json["Phone"] as? String ?? ""
        biography = json["Biography"] as? String ?? ""
        photo = json["Photo"] as? String ?? ""
    }
}
