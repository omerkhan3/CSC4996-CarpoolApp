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
import GeoFire
//creating references here for DB's rather than on individual pages allows for consistency in the structure of our DB.

let DB_Ref = Database.database().reference() // this is our reference to root of DB.
let geoFireRef = Database.database().reference().child("userLocation")  // this is our reference to the locations section of DB.
let geoFire = GeoFire(firebaseRef: geoFireRef) // we create an instance of GeoFire using the location reference.  This allows us to run GeoFire queries on "geoFire".

class DataService{
    static let inst = DataService()  // instantiation of DataService.
    
    private var _REF_BASE = DB_Ref
    private var _REF_USERS = DB_Ref.child("Users")
    
    var REF_BASE:  DatabaseReference{
        return _REF_BASE  // getter method for _REF_BASE
    }
    
    var REF_USERS : DatabaseReference{
        return _REF_USERS // getter method for _REF_USERS
    }
    
    func createUser(id: String, userInfo: Dictionary<String, Any>){
        REF_USERS.child(id).updateChildValues(userInfo)  // this is a function to create users in the DB.  Using this function throughout the program will allow for consistency as far as where we insert data.
    }
    
    func setUserLocation(location: CLLocation) {
        let uid = Auth.auth().currentUser?.uid // each user has a unique identifier generated by Firebase, which we will use to store locations under.
        geoFire.setLocation(location, forKey: uid!) // GeoFire insertion command.
    }
}
