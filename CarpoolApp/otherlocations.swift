//
//  otherlocations.swift
//  CarpoolApp
//
//  Created by Matt on 2/3/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//
import GeoFire
import Foundation
import MapKit
import AddressBook
import Firebase
import FirebaseDatabase
import FirebaseAuth


//connecting to firebase database
let DB_Ref = Database.database().reference()
let geoFireRef = Database.database().reference().child("userLocation")
let geoFire = GeoFire(firebaseRef: geoFireRef)



let center = CLLocation(latitude: 34.5, longitude: 21.3)

//Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
var circleQuery = geoFire.query(at: center,withRadius: 0.6)

// Query location by region
let span = MKCoordinateSpanMake(0.001, 0.001)
let region = MKCoordinateRegionMake(center.coordinate, span)
var regionQuery = geoFire.query(with: region)



class otherlocations: NSObject, MKAnnotation
{
    
    
    let title: String?
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    
    init (title: String, locationName: String?, coordinate: CLLocationCoordinate2D)
    {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    //will show the name of the locations plotted
    var subtitle: String? {
        return locationName
    }
    
    
    
    func mapItem() -> MKMapItem
    {
        let addressDictionary = [String(kABPersonAddressStreetKey) : subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = "\(title) \(subtitle)"
        
        return mapItem
    }
}


