//
//  DetailViewController.swift
//  Yelp
//
//  Created by Chau Vo on 9/6/15.
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
    
}

// MARK: - Google Maps

extension DetailViewController {

    func loadMap() {
        let camera = GMSCameraPosition.cameraWithLatitude(selectedBusiness.latitude!, longitude: selectedBusiness.longitude!, zoom: 15)
        mapView.camera = camera
        mapView.myLocationEnabled = true

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(selectedBusiness.latitude!, selectedBusiness.longitude!)
        marker.title = selectedBusiness.name!
        marker.map = mapView
    }

    func configDirectionView() {
        getDirectionView.layer.cornerRadius = 5
        getDirectionView.layer.borderWidth = 1
        getDirectionView.layer.borderColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0).CGColor

        let onGetDirection = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.onGetDirection(_:)))
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
        let sUrl = String(format: "http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&mode=driving", arguments: [myLocation.latitude, myLocation.longitude, lat, lng])

        let url = NSURL(string: sUrl)

        let request = NSURLRequest(URL: url!)

        do {
            let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)

            let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary

            if let json = json {
                let stepArray = json.valueForKeyPath("routes.legs.steps") as! NSArray
                let array = stepArray[0][0] as! [NSDictionary]

                // Add the 1st location (my location)
                destLocationArray.append(myLocation)
                for step in array {
                    let desLat = step.valueForKeyPath("end_location.lat") as! Double
                    let desLng = step.valueForKeyPath("end_location.lng") as! Double
                    self.destLocationArray.append(Location(lat: desLat, lng: desLng))
                    //println("lat: \(desLat), lng: \(desLng)")
                }
            }

        } catch  { }
    }

    func showDirection() {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(myLocation.latitude, myLocation.longitude)
        marker.title = "My location"
        marker.icon = UIImage(named: "MyLocation")
        marker.map = mapView

        let path = GMSMutablePath()
        for location in destLocationArray {
            path.addLatitude(CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude))
        }

        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor(red: 213/255, green: 28/255, blue: 24/255, alpha: 1.0)
        polyline.strokeWidth = 5
        polyline.map = mapView
    }

}
