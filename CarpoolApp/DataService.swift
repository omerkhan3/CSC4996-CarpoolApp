//
//  DataService.swift
//  CarpoolApp
//
//  Created by Omer  Khan on 2/1/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

let DB_Ref = Database.database().reference()

class DataService{
    static let inst = DataService()
    
    private var _REF_BASE = DB_Ref
    private var _REF_USERS = DB_Ref.child("Users")
    
    var REF_BASE:  DatabaseReference{
        return _REF_BASE
    }
    
    var REF_USERS : DatabaseReference{
        return _REF_USERS
    }
    
    func createUser(id: String, userInfo: Dictionary<String, Any>){
        REF_USERS.child(id).updateChildValues(userInfo)
    }
}