import Foundation
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class EmbeddedNavViewController: UIViewController, NavigationViewControllerDelegate, UITextFieldDelegate  {
 
    @IBOutlet weak var container: UIView!
    var route: Route?

    @IBOutlet weak var pickedUp: RoundedButton!
    @IBOutlet weak var droppedOff: RoundedButton!
    @IBOutlet weak var cancelDrive: RoundedButton!
    
    let origin = Waypoint(coordinate: CLLocationCoordinate2DMake(42.382184, -82.940201), name: "matts place")
  let destination = Waypoint(coordinate: CLLocationCoordinate2DMake(42.359139, -83.066546), name: "wayne state")
    let riderPickup = Waypoint(coordinate: CLLocationCoordinate2DMake(42.3840825, -82.9412279), name: "1320 Lakepointe")
    let riderDropoff = Waypoint(coordinate: CLLocationCoordinate2DMake(42.3863712, -82.942725), name:"1420 Lakepointe")
        
    @IBAction func pickPress(_ sender: RoundedButton) {
        //cancelDrive.isEnabled = false
        cancelDrive.alpha = 0.2
    }
    
    @IBAction func dropPress(_ sender: RoundedButton) {
        //cancelDrive.isEnabled = true
        cancelDrive.alpha = 1.0
     
    }
    
    @IBAction func cancelPress(_ sender: RoundedButton) {
        
        var actionItem : String=String()
        var actionTitle : String=String()
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        // default action to exit out of native alerts.
        if cancelDrive.alpha != 1.0 {
            actionTitle = "Error!"
            actionItem = "You can not cancel ride in the middle of a route."
            
            // Activate UIAlertController to display error
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(exitAction)
            self.present(alert, animated: true, completion: nil)
        }
        else if cancelDrive.alpha == 1.0 {
            print("hi")
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateDirections()
    }
    
    func calculateDirections() {
    let options = NavigationRouteOptions(waypoints: [origin, riderPickup, riderDropoff, destination], profileIdentifier: . automobile)
    _ = Directions.shared.calculate(options) { (waypoints, routes, error) in
            guard let route = routes?.first, error == nil else {
                print(error!.localizedDescription)
                return
            }
            self.route = route
            self.startEmbeddedNavigation()
        }
    }

    func startEmbeddedNavigation() {
        let nav = NavigationViewController(for: route!)
        
        // simulate the route.
        nav.routeController.locationManager = SimulatedLocationManager(route: route!)
        
        nav.delegate = self
        addChildViewController(nav)
        container.addSubview(nav.view)
        nav.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nav.view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            nav.view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
            nav.view.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            nav.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
            ])
        self.didMove(toParentViewController: self)
    }
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
        
        
        
        let alert = UIAlertController(title: "Arrived at \(String(describing: waypoint.name))", message: "Would you like to continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            // Begin the next leg once the driver confirms
            navigationViewController.routeController.routeProgress.legIndex += 1
        }))
        navigationViewController.present(alert, animated: true, completion: nil)
        
        return false
    }
    
}
