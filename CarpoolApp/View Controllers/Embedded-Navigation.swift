import Foundation
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class EmbeddedExampleViewController: UIViewController, NavigationViewControllerDelegate  {
 
    @IBOutlet weak var container: UIView!
    var route: Route?

    lazy var options: NavigationRouteOptions = {
        let origin = CLLocationCoordinate2DMake(42.382184, -82.940201)
        let destination = CLLocationCoordinate2DMake(42.359139, -83.066546)
        return NavigationRouteOptions(coordinates: [origin, destination])
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateDirections()
    }

    
    func calculateDirections() {
        Directions.shared.calculate(options) { (waypoints, routes, error) in
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
        
        // This allows the developer to simulate the route.
        // Note: If copying and pasting this code in your own project,
        // comment out `simulationIsEnabled` as it is defined elsewhere in this project.
        
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

    //MARK: - NavigationViewControllerDelegate
    
}

