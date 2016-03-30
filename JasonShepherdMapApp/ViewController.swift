//
//  ViewController.swift
//  JasonShepherdMapApp
//
//  Created by Jason Shepherd on 3/30/16.
//  Copyright © 2016 Salt Lake Community College. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    // Location attribute
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Getting the user location
        locationManager.delegate = self // Set delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Set accuracy level
        locationManager.requestWhenInUseAuthorization() // Set authorization level
        locationManager.startUpdatingLocation() // Start updating user's location
        
        // Building a map region with detailed variables
        
        // Variables to hold latitude and longitude
        var latitude:CLLocationDegrees = 40.672640
        var longitude:CLLocationDegrees = -111.942339
        
        // Delta variables to hold the difference of latitude and longitude from one side of the screen to the other
        // Controls zoomed level of latitude and longitude. Lower value zooms in.
        let latDelta:CLLocationDegrees = 0.01
        let lonDelta:CLLocationDegrees = 0.01
        
        // Sets both latitude and longitude zoom
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        // Sets both latitude and longitude zoom
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        // Sets the latitude and longitude on the map itself
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        // Set the map to the region
        map.setRegion(region, animated: true)
        
        // Adding annotations to the map
        
        // Creating annotation object from MapKit
        let annotation = MKPointAnnotation()
        
        // Using annotation object and set its attributes
        annotation.coordinate = location // location of SLCC via latitude and longitude set above
        annotation.title = "Salt Lake Community College" //set title attribute
        annotation.subtitle = "CSIS2640 iOS Programming" //set subtitle attribute
        map.addAnnotation(annotation) //add the annotation object to the map object
        
        // Adding a long press object 
        
        // target: is the self or this ViewController
        // action: is the function to run when long press is recognized
        var longPress = UILongPressGestureRecognizer(target: self, action: "action:")
        
        // Set the press duration attribute of the longPress object
        longPress.minimumPressDuration = 2
        
        // Add the long press recognizer to the map
        map.addGestureRecognizer(longPress)
    
    }

    // Function to perform when a long press happens on the map
    // theLongPress is the gesture sent from action:
    func action(theLongPress:UIGestureRecognizer) {
        
        // Print to console to show active
        print("User Long Pressed")
        
        // userTouch relative to point on current map
        let userTouch = theLongPress.locationInView(self.map)
        
        // Convert userTouch to coordinate
        let userCoordinate: CLLocationCoordinate2D = map.convertPoint(userTouch, toCoordinateFromView: self.map)
        
        // Creating annotation object from MapKit
        let annotation = MKPointAnnotation()
        
        // Using annotation object and set its attributes
        annotation.coordinate = userCoordinate // location of SLCC via latitude and longitude set above
        annotation.title = "" //set title attribute
        annotation.subtitle = "" //set subtitle attribute
        map.addAnnotation(annotation) //add the annotation object to the map object
        
    }
    
    // This function is called every time a new location is registered by the phone.
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [CLLocation]!) {
        
        // Set user location with latitude and longitude
        let userLocation:CLLocation = locations[0] as CLLocation
        var latitude = userLocation.coordinate.latitude
        var longitude = userLocation.coordinate.longitude
        
        // Delta variables to hold the difference of latitude and longitude from one side of the screen to the other
        // Controls zoomed level of latitude and longitude. Lower value zooms in.
        let latDelta:CLLocationDegrees = 0.1
        let lonDelta:CLLocationDegrees = 0.1
        
        // Sets both latitude and longitude zoom
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        // Sets both latitude and longitude zoom
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        // Sets the latitude and longitude on the map itself
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        // Set the map to the region
        self.map.setRegion(region, animated: true)
        
     
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

