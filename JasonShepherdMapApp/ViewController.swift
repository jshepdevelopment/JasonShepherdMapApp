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

// Declaring a class for a modal viewer
class ModalViewController: UIViewController, UITableViewDelegate {
    
    // Array to store location information
    var historyListPassed = [String]()
    
    @IBOutlet weak var tripHistoryTable: UITableView!
    
    @IBOutlet var tripView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("historyListPassed.count: \(historyListPassed.count)")
        return historyListPassed.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: "cell")
        
        //cell.textLabel?.text = toDoList[indexPath.row]
        //cell.textLabel?.text = "Trip \(historyListPassed[0]) Start Location:"
        cell.detailTextLabel!.numberOfLines = 3
        //cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.detailTextLabel?.text = historyListPassed[indexPath.row]
        
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        tripHistoryTable.reloadData()
    }

}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // Variable to handle flashing light state
    var faded = false

    // Handles report update timer
    var timerValue = 1
    var userLocation:CLLocation = CLLocation(latitude: 0, longitude: 0)
    var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var reportValue = 0
    var tracking = false
    
    var reportTimer:NSTimer!
    var animTimer:NSTimer!
    
    // Variables to store locations
    var locationNameString = ""
    var cityString = ""
    var streetString = ""
    var zipString = ""
    var countryString = ""
    
    var multiStringList = [String]()
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var redFlash: UIImageView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var sliderVal: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    // Update slider value
    @IBAction func sliderValueChanged(sender: UISlider) {
        timerValue = Int(slider.value)
        sliderVal.text = "\(timerValue)"
    }
    
    @IBAction func startButton(sender: AnyObject) {
        
        if !tracking {
        // Build a timer to run flashing button
            animTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(ViewController.updateRedFlash), userInfo: nil, repeats: true)
            
            // Build timer for reporting locations
            reportTimer = NSTimer.scheduledTimerWithTimeInterval(Double(timerValue*60), target: self, selector: #selector(ViewController.updateReport), userInfo: nil, repeats: true)
            tracking = true
        }
        
        /*if tracking {
            tracking = false
            startBtn.setTitle("Start", forState: UIControlState.Normal)
            
        }*/
    }
    
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
        let latitude:CLLocationDegrees = 40.672640
        let longitude:CLLocationDegrees = -111.942339
        
        // Delta variables to hold the difference of latitude and longitude from one side of the screen to the other
        // Controls zoomed level of latitude and longitude. Lower value zooms in.
        let latDelta:CLLocationDegrees = 0.01
        let lonDelta:CLLocationDegrees = 0.01
        
        // Sets both latitude and longitude zoom
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        // Sets both latitude and longitude zoom
        location = CLLocationCoordinate2DMake(latitude, longitude)
        
        // Sets the latitude and longitude on the map itself
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        // Set the map to the region
        map.setRegion(region, animated: true)
        
        // Adding a long press object
        
        // target: is the self or this ViewController
        // action: is the function to run when long press is recognized
        var longPress = UILongPressGestureRecognizer(target: self, action: "action:")
        
        // Set the press duration attribute of the longPress object
        longPress.minimumPressDuration = 2
        
        // Add the long press recognizer to the map
        map.addGestureRecognizer(longPress)

    }
    
    
    // Update the red flashing thingy
    func updateRedFlash() {
        
        if !faded {
        
            UIView.animateWithDuration(0.01, delay: 0.01, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.redFlash.alpha = 0.0
            }, completion: nil)
            
            faded = true
            
        } else {
            UIView.animateWithDuration(0.01, delay: 0.01, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.redFlash.alpha = 1.0
                }, completion: nil)
            
            faded = false
        }
        
    }
    
    // Update the trip report
    func updateReport() {
        getLocation()
        reportValue += 1
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
        annotation.title = "Some Place" //set title attribute
        annotation.subtitle = "You pressed here." //set subtitle attribute
        map.addAnnotation(annotation) //add the annotation object to the map object
        
    }
    
    // This function is called every time a new location is registered by the phone.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Set user location with latitude and longitude
        userLocation = locations[0] as CLLocation
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        // Delta variables to hold the difference of latitude and longitude from one side of the screen to the other
        // Controls zoomed level of latitude and longitude. Lower value zooms in.
        let latDelta:CLLocationDegrees = 0.1
        let lonDelta:CLLocationDegrees = 0.1
        
        // Sets both latitude and longitude zoom
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        // Sets both latitude and longitude zoom
        location = CLLocationCoordinate2DMake(latitude, longitude)
        
        // Sets the latitude and longitude on the map itself
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        // Set the map to the region
        self.map.setRegion(region, animated: true)
        
        //print("locations = \(latitude) \(longitude)")
        
    }
    
    // get the locatation via reverse geocoding
    func getLocation() {
        
        // Set timestamp
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        // Set speed and altitude
        let speed = locationManager.location!.speed
        let altitude = locationManager.location!.altitude
        
        
        // Used to Geocoder for reverse geocoding
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(userLocation, completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if placemarks!.count > 0 {
                let placeMark = placemarks![0]
                
                // Location name
                if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                    //print(locationName)
                    self.locationNameString = String(locationName)
                    //print(self.locationNameString)
                }
                // Street address
                if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                    //print(street)
                    self.streetString = String(street)
                    //print(self.streetString)
                }
                
                // City
                if let city = placeMark.addressDictionary!["City"] as? NSString {
                    //print(city)
                    self.cityString = String(city)
                    //print(self.cityString)
                }
                
                // Zip code
                if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                    //print(zip)
                    self.zipString = String(zip)
                }
                // Country
                if let country = placeMark.addressDictionary!["Country"] as? NSString {
                    //print(country)
                    self.countryString = String(country)
                }
                
                //Update trip array
                
                self.multiStringList.append("\(timestamp): \(self.locationNameString) \(self.streetString) \(self.cityString) \(self.zipString)  \(self.countryString), speed: \(speed), altitude: \(altitude)")
                //print("Trip report updated.")
                print("multiStringList.count: \(self.multiStringList.count)")
                
            } else {
                print("Problem with the data received from geocoder")
            }
            
        })
        
        // Creating annotation object from MapKit
        let annotation = MKPointAnnotation()
        
        // Using annotation object and set its attributes
        annotation.coordinate = location // location of SLCC via latitude and longitude set above
        annotation.title = "\(locationNameString)" //set title attribute
        annotation.subtitle = "\(cityString)" //set subtitle attribute
        map.addAnnotation(annotation) //add the annotation object to the map object

    }
    
    
    //Sending data to table in segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "showHistorySegue") {
            let svc = segue.destinationViewController as! ModalViewController;
            //print(multiStringList)
            
            svc.historyListPassed = multiStringList
            print("segue passed")
            if animTimer != nil {
                animTimer.invalidate()
            }
            if reportTimer != nil {
                reportTimer.invalidate()
            }
            tracking = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

