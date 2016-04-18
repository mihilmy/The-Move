//
//  MapViewColor.swift
//  Events
//
//  Created by Harsha Cuttari on 2/14/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse
import Mapbox




class MapViewColor: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate {

    // Add event button, could be changed to one button.
    @IBOutlet var addEventButtonBlack: UIButton!
    @IBOutlet var addEventButtonWhite: UIButton!
    // A view to add the map on.
    @IBOutlet var colorMapView: UIView!
    // The actual map to be modified.
    var mapView: MGLMapView!
    // Used to find the current user's location.
    var locationManager = CLLocationManager()
    // Getting the current hour for the user.
    let currentHour = NSDate().hour()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adjust the user's first and last names.
        firstName = PFUser.currentUser()!["first_name"] as! String
        lastName = PFUser.currentUser()!["last_name"] as! String
        
        
        // Adjusting finding your current location.
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        //
        self.mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.mapView.showsUserLocation = true
        self.mapView.attributionButton.hidden = true
        colorMapView.addSubview(mapView)
        self.mapView.delegate = self

        
    }
    
    // Might possibly remove this from the application.
    override func viewDidAppear(animated: Bool) {
        // fromDistance: is meters above mean sea level that an eye would have to be in order to see what the map view is showing.
        let camera = MGLMapCamera(lookingAtCenterCoordinate: mapView.centerCoordinate, fromDistance: 1000, pitch: 0, heading: 0)
        
        // Animate the camera movement over 2 seconds.
        mapView.setCamera(camera, withDuration: 2, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        // Updating the map color depending on the time.
        if ((currentHour > 6) && (currentHour < 20 )){
            mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.lightStyleURL())
            addEventButtonBlack.hidden = false
            addEventButtonWhite.hidden = true
        } else {
            mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.darkStyleURL())
            addEventButtonBlack.hidden = true
            addEventButtonWhite.hidden = false
        }
        
        // Add the pins to the map.
        addPins()

    }
    
    // Can show a call out if it's our custom event pin only. If this is removed the user's location will also have one.
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        if annotation is CustomPinAnnotation{
            return true
        }else{
            return false
        }
        
    }
    
    // Adding the detail info button for the call out.
    func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        let detailButton = UIButton(type: UIButtonType.DetailDisclosure)
        return detailButton
    }
    
    // Moving to the events page.
    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // hide the callout view
        mapView.deselectAnnotation(annotation, animated: true)
        let w = annotation as! CustomPinAnnotation
        SelectedEvent = w.moveObject
        let eventDetailsPage = storyboard?.instantiateViewControllerWithIdentifier("EventDetails") as! EventDeats
        navigationController?.pushViewController(eventDetailsPage, animated: true)
    }
    
    // Setting the users current location and zoom level.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        self.mapView.setCenterCoordinate(center, zoomLevel: 15, animated: false)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    
    func addPins(){
        let moves = queryMovesWithin(540000)
        
        for move in moves{
            // Gets the geopoints from the moves table
            let geoLocation = move["location"] as! PFGeoPoint
            // Add the pin to the map
            let annotation = CustomPinAnnotation()
            annotation.title = move["title"] as? String
            annotation.moveObject = move
            // Add the coordinate
            annotation.coordinate = CLLocationCoordinate2DMake(geoLocation.latitude, geoLocation.longitude)
            // Add to the map
            self.mapView.addAnnotation(annotation)
        }
    }
    
    
    @IBAction func refreshButt(sender: AnyObject) {
        addPins()

    }
    
    
    
}