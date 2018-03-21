//
//  NavigationViewController.swift
//  CarpoolApp
//
//  Created by Matt on 3/21/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Mapbox
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

class NavViewController: UIViewController, MGLMapViewDelegate {

    var mapView: MGLMapView!
    let mapCenter = CLLocationCoordinate2D(latitude:30.3333, longitude:-97.741)
    let origin = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047), name: "Mapbox")
    let destination = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), name: "White House")
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = NavigationMapView(frame: view.bounds, styleURL: MGLStyle.streetsStyleURL())
        view.addSubview(mapView)
        mapView.delegate = self
        //center map
        mapView.setCenter(mapCenter, zoomLevel: 11, animated: false)
        
        //get and show directions
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
        _ = Directions.shared.calculate(options) { (waypoints,route,error) in
            guard let route = route?.first else {return}
            print(route.coordinates)
            for step in (route.legs.first?.steps)!{
                print(step)
            }
            let NavViewController = NavigationViewController(for: route, locationManager:SimulatedLocationManager(route: route))
            self.present(NavViewController,animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
 

}
