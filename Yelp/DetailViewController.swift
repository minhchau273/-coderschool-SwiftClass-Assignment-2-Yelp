//
//  DetailViewController.swift
//  Yelp
//
//  Created by Dave Vo on 9/6/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var reviewCountLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var categoriesLabel: UILabel!
    
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var ratingStarView: UIImageView!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var getDirectionView: UIView!
    

    var selectedBusiness: Business!
    
    var destLocationArray = [Location]()
    
    let myLocation = Location(lat: 37.785771, lng: -122.406165)
    
    var showedDirection = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDetail()
        loadMap()
        configDirectionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadDetail() {
        self.title = selectedBusiness.name
        nameLabel.text = selectedBusiness.name
        reviewCountLabel.text = "\(selectedBusiness.reviewCount!) Reviews"
        statusLabel.text = selectedBusiness.status
        categoriesLabel.text = selectedBusiness.categories
        phoneLabel.text = selectedBusiness.phone
        distanceLabel.text = selectedBusiness.distance
        addressLabel.text = selectedBusiness.displayAddress
        ratingStarView.setImageWithURL(selectedBusiness.ratingImageURL)
        imageView.setImageWithURL(selectedBusiness.imageURL)
    }
    
    func loadMap() {
        
        var camera = GMSCameraPosition.cameraWithLatitude(selectedBusiness.latitude!, longitude: selectedBusiness.longitude!, zoom: 15)
        mapView.camera = camera
        mapView.myLocationEnabled = true
        
        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(selectedBusiness.latitude!, selectedBusiness.longitude!)
        marker.title = selectedBusiness.name!
        marker.map = mapView
    }
    
    func configDirectionView() {
        
        getDirectionView.layer.cornerRadius = 5
        getDirectionView.layer.borderWidth = 1
        getDirectionView.layer.borderColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0).CGColor
        
        let onGetDirection = UITapGestureRecognizer(target: self, action: "onGetDirection:")
        getDirectionView.addGestureRecognizer(onGetDirection)
    }
    
    // MARK: Get direction
    
    func onGetDirection(sender:UITapGestureRecognizer) {
        
        if !showedDirection {
            getDirection(selectedBusiness.latitude!, lng: selectedBusiness.longitude!)
            showDirection()
            
            showedDirection = true
        }
    }

    func getDirection(lat: Double, lng: Double) {
        
        var sUrl = String(format: "http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&mode=driving", arguments: [myLocation.latitude, myLocation.longitude, lat, lng])
        
        let url = NSURL(string: sUrl)
        
        let request = NSURLRequest(URL: url!)
        
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
        let json = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as? NSDictionary
        
        if let json = json {
            var stepArray = json.valueForKeyPath("routes.legs.steps") as! NSArray
            var array = stepArray[0][0] as! [NSDictionary]
            
            // Add the 1st location (my location)
            destLocationArray.append(myLocation)
            for step in array {
                var desLat = step.valueForKeyPath("end_location.lat") as! Double
                var desLng = step.valueForKeyPath("end_location.lng") as! Double
                self.destLocationArray.append(Location(lat: desLat, lng: desLng))
                println("lat: \(desLat), lng: \(desLng)")
            }
        }
    }
    
    func showDirection() {
    
        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(myLocation.latitude, myLocation.longitude)
        marker.title = "My location"
        marker.icon = UIImage(named: "MyLocation")
        marker.map = mapView
        
        var path = GMSMutablePath()
        for location in destLocationArray {
            path.addLatitude(CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude))
        }
        
        var polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor(red: 213/255, green: 28/255, blue: 24/255, alpha: 1.0)
        polyline.strokeWidth = 5
        polyline.map = mapView
    }

}
