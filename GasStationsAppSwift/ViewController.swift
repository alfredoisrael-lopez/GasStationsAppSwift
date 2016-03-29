//
//  ViewController.swift
//  GasStationsAppSwift
//
//  Created by Alfredo Israel López Alcalá on 26/03/2016.
//  Copyright © 2016 Alfredo Lopez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import IBMMobileFirstPlatformFoundation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 45/255, green: 174/255, blue: 206/255, alpha: 1)
        
        //To take the current position
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04))
        
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
        let connectionListener = GasStationListener()
        WLClient.sharedInstance().wlConnectWithDelegate(connectionListener)
        
        let request = WLResourceRequest(URL: NSURL(string: "/adapters/GasStationsAdapter/findAroundMe"), method: WLHttpMethodPost)
        
        let numLat = NSNumber(double: (location?.coordinate.latitude)! as Double)
        let latitude:String = numLat.stringValue
        
        let numLon = NSNumber(double: (location?.coordinate.longitude)! as Double)
        let longitude: String = numLon.stringValue
        
        let params = "[\"\(longitude)\",\"\(latitude)\",\"10\",\"3\"]"
        
        request.sendWithFormParameters(["params": params], completionHandler: { (response, error) -> Void in
            if (error != nil) {
                print("Error: " + error.description)
            }
            else if (response != nil) {
                
                let jsonObject: NSDictionary? = response.getResponseJson()
                let gasStations: NSArray? = jsonObject?.objectForKey("gasStations") as? NSArray
                for (gasStation) in gasStations! {
                    let location = gasStation.objectForKey("location") as? NSDictionary
                    let coordinates = location?.objectForKey("coordinates") as? NSArray
                    
                    let annotationCoordinate = CLLocationCoordinate2D(latitude: ((coordinates![1]).doubleValue as CLLocationDegrees), longitude: ((coordinates![0]).doubleValue as CLLocationDegrees))
                    
                    let gasAnnotation = MKPointAnnotation()
                    gasAnnotation.title =  gasStation.objectForKey("name") as? String
                    
                    gasAnnotation.coordinate = annotationCoordinate
                    
                    self.mapView.addAnnotation(gasAnnotation)
                }
                
            }
        })
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors --> " + error.localizedDescription)
    }
    
    
}

