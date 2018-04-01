//
//  HelperFunctions.swift
//  CarpoolAppUITests
//
//  Created by Omer  Khan on 4/1/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation
import XCTest

extension XCUIApplication {
    var isDisplayingLogin: Bool {
        return otherElements["loginView"].exists
    }
    var isDisplayingDashboard: Bool {
        return otherElements["dashboardView"].exists
    }
    
    var isDisplayingRegistration: Bool {
        return otherElements["registrationView"].exists
    }
    
    func randomString() -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = 7
        
        var randomString = ""
        
        for _ in 0 ..< 7 {
            let rand = arc4random_uniform(UInt32(len))
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
