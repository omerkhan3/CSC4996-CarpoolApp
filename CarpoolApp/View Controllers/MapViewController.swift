//
//  MapViewController.swift
//  CarpoolApp
//
//  Created by Matt on 2/1/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth

//MOE
protocol MapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var mapMatchDetail: Match?
    
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    
    // Class variables
    let locationManager = CLLocationManager()
    var ref: DatabaseReference! // Creates database reference
    var currentPlacemark:CLPlacemark?
    // var centerMapped = false
    

    //linking mapview to this class
    @IBOutlet weak var mapView: MKMapView!
    
    
//    @IBAction func showDirection(_ sender: Any) {
//        //makes sure to get location from destination location rather than users current location
//        guard let currentPlacemark = currentPlacemark else{
//            print("returning")
//            return
//        }
//
//        let directionRequest = MKDirectionsRequest()
//        let destinationPlacemark = MKPlacemark(placemark:currentPlacemark)
//        print(destinationPlacemark)
//
//
//        //set source of the direction request
//        directionRequest.source = MKMapItem.forCurrentLocation()
//        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
//        directionRequest.transportType = .automobile
//
//        // determine the directions/route, and check for any errors along the way
//        let directions = MKDirections(request: directionRequest)
//        directions.calculate { (directionsResponse, error) in
//            //if directions response is nil, else case gets called
//            guard let directionsResponse = directionsResponse else {
//                if let error = error{
//                    print("Error getting directions: \(error.localizedDescription)")
//                }
//                return
//            }
//            //selecting 0 means will choose shortest route
//            let route = directionsResponse.routes[0]
//            //show the line above the roads and remove each overlay when different annotation is selected
//            self.mapView.removeOverlays(self.mapView.overlays)
//            self.mapView.add(route.polyline, level: .aboveRoads)
//
//            //zoom in on route once polyline is drawn
//            let routeRect = route.polyline.boundingMapRect
//            self.mapView.setRegion(MKCoordinateRegionForMapRect(routeRect), animated: true)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let destionationName = mapMatchDetail?.driverRouteName
        let destinationLat = mapMatchDetail?.driverEndPointLat
        let destinationLong = mapMatchDetail?.driverEndPointLong
        
        // Hard code user's start point until we get the query
        let startName = "Home"
        let startLat = 42.6543464660645
        let startLong = -83.1790237426758
        
        // Set up Map
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        mapView.showsUserLocation = true
        //first sample location
        let destination = otherlocations(title: destionationName!,
                                         locationName: "Destination",
                                         coordinate: CLLocationCoordinate2D(latitude: destinationLat!, longitude: destinationLong!))
        self.mapView.addAnnotation(destination)
        
        let startingPoint = otherlocations(title: startName, locationName: "Start", coordinate: CLLocationCoordinate2D(latitude: startLat, longitude: startLong))
        self.mapView.addAnnotation(startingPoint)
        
        let startingCoordinate = CLLocationCoordinate2D(latitude: startLat, longitude: startLong)
        let destinationcoordinate = CLLocationCoordinate2D(latitude: destinationLat!, longitude: destinationLong!)
        
        showRouteOnMap(start: startingCoordinate, destination: destinationcoordinate)
    }

    //Brings up the user on the map after authorization
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
    }
    
    func showRouteOnMap(start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        
        let startPlacemark = MKPlacemark(coordinate: start, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destination, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: startPlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = startPlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Get directions
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("error")
                }
                
                return
            }
            
            let route = response.routes[0]
            
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            
        }
        
    }
    
    //selecting an annotation will call this method
    func mapView(_ mapView:MKMapView, didSelect view:MKAnnotationView)
    {
        //grab annotation from current location
        if let location = view.annotation as? otherlocations{
        self.currentPlacemark = MKPlacemark(coordinate: location.coordinate)
        }
    }
    //function that is called when polygon line is drawn, can set size and color
    func mapView(_ mapView:MKMapView, rendererFor overlay:MKOverlay) ->MKOverlayRenderer
    {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.green
        renderer.lineWidth = 3.5
        
        return renderer
    }

    
    //make sure user accepts location request, if they havent already, then prompt them to
    func locationAuthStatus ()
    {
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        } else {
           locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
}

//Uses the protocol we created mapsearch, clears map of any other annotations on it, and mkpointannotation has the coordinate, subtitle(city, state), and title of the place(ex. H&M)
extension MapViewController: MapSearch {
    func dropPinZoomIn(placemark:MKPlacemark) {
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        //Add the annotation stated above(city, state)
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        //Will zoom in the map to the coordinate of the place chosen
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

