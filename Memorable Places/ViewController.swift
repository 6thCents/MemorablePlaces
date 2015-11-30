//
//  ViewController.swift
//  Memorable Places
//
//  Created by David Rollins on 11/25/15.
//  Copyright © 2015 David Rollins. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        MapAddress()
        searchBar.resignFirstResponder();
    }
    
    private func MapAddress(){
        
        let address = searchBar.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!) { (placemarks, error) -> Void in
            if error == nil {
                if let p:CLPlacemark = placemarks![0]  {
                    
                    
                    //delta = the different in lat or long from one side of the map to the other
                    // the smaller the number the more you are zoomed in
                    // 1 =  very zoomed out
                    // 0.00001 - very zoomed in
                    
                    let latDelta: CLLocationDegrees = 0.01
                    let lonDelta: CLLocationDegrees = 0.01
                    
                    
                    let span:MKCoordinateSpan =  MKCoordinateSpanMake(latDelta, lonDelta)

                    // pull out coordinates from placemark
                    let location:CLLocationCoordinate2D = (p.location?.coordinate)!
                    
                    let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
                    
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.showsUserLocation = true
                    
//                    let annotation = MKPointAnnotation()
//                    
//                    annotation.coordinate = location
//                    
//                    annotation.title = "Sydney Opera House"
//                    
//                    // ~max length of subtitle used here
//                    annotation.subtitle  = "Tuesday Phantom of the Opera is playing - I wonder how "
//                    
//                    self.mapView.addAnnotation(annotation)
                    
                    // colon at end of action name tells recognizer to send itself as a parameter
                    let uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
                    
                    // 1 second seems about right from a UX perspective
                    uilpgr.minimumPressDuration = 1
                    
                    self.mapView.addGestureRecognizer(uilpgr)
                }
            }
        }
    }
    
    // will add a pin to a map
    func action(gestureRecognizer: UIGestureRecognizer){
        
        //"map" being the name of the control we placed on the view controller
        // point the user has pressed on relative to the map NOT world coordinates
        let touchPoint = gestureRecognizer.locationInView(self.mapView)

        let alertController = UIAlertController(title: "Favorite Place",
            message: "Name your place below",
            preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler(
            {(textField: UITextField!) in
                textField.placeholder = "Enter name of place"
        })
        
        let okAction = UIAlertAction(title: "Save",
            style: UIAlertActionStyle.Default,
            handler: {[weak self]
                (paramAction:UIAlertAction!) in
                if let textFields = alertController.textFields{
                    let theTextFields = textFields as [UITextField]
                    let enteredText = theTextFields[0].text
 
                    // convert to real coordinates
                    let newCoordinate: CLLocationCoordinate2D = self!.mapView.convertPoint(touchPoint, toCoordinateFromView: self!.mapView)
                    
                    // now add the annotation
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = newCoordinate
                    annotation.title = enteredText
                    annotation.subtitle  = "One of my favorite places"
                    
                    var aplace:Place = Place()
                    aplace.address = self!.searchBar.text!
                    aplace.coordinate = newCoordinate
                    aplace.name = enteredText!
                    
                    // add this place to the list
                    myplaces.append(aplace)
                    
                    // place new pin on map with user-defined title and sub title
                    self!.mapView.addAnnotation(annotation)
                }
            })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController,
            animated: true,
            completion: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if selectedidx >= 0 {
            let place:Place = myplaces[selectedidx]
            ShowCoordinatesOnMap(place)
        }
    }
    
    func ShowCoordinatesOnMap(place:Place) {
        
        
        let latDelta: CLLocationDegrees = 0.01
        let lonDelta: CLLocationDegrees = 0.01
        
        
        let span:MKCoordinateSpan =  MKCoordinateSpanMake(latDelta, lonDelta)
        
        let location:CLLocationCoordinate2D = place.coordinate
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = place.coordinate
        annotation.title = place.name
        annotation.subtitle  = "One of my favorite places"
        
        // place new pin on map with user-defined title and sub title
        mapView.addAnnotation(annotation)
        
        self.mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true

    }
    
}

