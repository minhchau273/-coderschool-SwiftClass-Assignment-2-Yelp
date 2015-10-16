//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Dave Vo on 9/2/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import UIKit
import GoogleMaps

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noResultLabel: UILabel!
    
    @IBOutlet weak var mapButton: UIBarButtonItem!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var totalResult = 0 as Int
    var businesses : [Business]!
    var searchBar = UISearchBar()
    var keyword = "Restaurants"
    var filters = [String : AnyObject]()
    var tableFooterView: UIView!
    var loadingView: UIActivityIndicatorView!
    var notificationLabel: UILabel!
    
    let meterConst = 1609.344 as Float

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorColor = UIColor(red: 238/255, green: 180/255, blue: 180/255, alpha: 1)

        tableView.accessibilityLabel = "BusinessesTableView"
        
        addTableFooterView()
        
        Business.searchWithTerm(nil, completion: { (result: Result!, error: NSError!) -> Void in
            
            if result != nil {
                self.totalResult = result.total!
                self.businesses = result.businesses
                self.tableView.reloadData()
                self.createMarkers()
                
                //            for business in self.businesses {
                //                println(business.name!)
                //                println(business.address!)
                //            }

            } else {
                self.totalResult = 0
            }
            
            self.setTableViewVisible()
        })
        
        searchBar.delegate = self
        searchBar.accessibilityLabel = "Search Bar"
        self.navigationController?.navigationBar.addSubview(searchBar)
        
        mapView.delegate = self
        mapView.hidden = true
        
    }
    
    override func viewDidLayoutSubviews() {
        // When rotate device
        
        // Change size of search bar
        var navBarHeight = self.navigationController?.navigationBar.frame.height
        var y = (navBarHeight! - 30) / 2
        let screenWidth = CGRectGetWidth(tableView.superview!.frame)
        searchBar.frame = CGRect(x: 53, y: y, width: screenWidth - 100, height: 30)
        
        // Change size of the loading icon
        tableFooterView.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(tableView.superview!.frame), height: 50)
        notificationLabel.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(tableView.superview!.frame), height: 50)
        loadingView.center = tableFooterView.center
        loadingView.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table view
    
    func addTableFooterView() {
        
        tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(tableView.superview!.frame), height: 50))
        println("width: \(tableFooterView.frame.width)")
        loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingView.startAnimating()
        loadingView.center = tableFooterView.center
        tableFooterView.addSubview(loadingView)
        
        notificationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(tableView.superview!.frame), height: 50))
        notificationLabel.text = "No more results"
        notificationLabel.textAlignment = NSTextAlignment.Center
        notificationLabel.hidden = true
        tableFooterView.addSubview(notificationLabel)
        
        tableView.tableFooterView = tableFooterView
    }
    
    func setTableViewVisible() {
        
        if totalResult > 0 {
            var buttonImg = mapButton.image
            if buttonImg == UIImage(named: "Map") {
                tableView.hidden = false
                mapView.hidden = true
            } else {
                tableView.hidden = true
                mapView.hidden = false
            }
            noResultLabel.hidden = true
        } else {
            tableView.hidden = true
            mapView.hidden = true
            noResultLabel.hidden = false
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        cell.nameLabel.text = String(indexPath.row + 1) + ". " + businesses[indexPath.row].name!
        
        if indexPath.row == businesses.count - 1 {
     
            if businesses.count < totalResult {
                loadingView.startAnimating()
                notificationLabel.hidden = true
                searchBusisness()
                
            } else {
                loadingView.stopAnimating()
                notificationLabel.hidden = false
            }
        }
        
        // Set full width for the separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        
        return cell
    }
    
    // MARK: Transfer between 2 view controllers
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let navigationController = segue.destinationViewController as! UINavigationController
        
        if navigationController.topViewController is FiltersViewController {
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            filtersViewController.delegate = self
        } else if navigationController.topViewController is DetailViewController {
            let detailViewController = navigationController.topViewController as! DetailViewController
            
            var indexPath: AnyObject!
            indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
            
            detailViewController.selectedBusiness = businesses[indexPath!.row]
        }
    }
    
    func filtersViewController(filFiltersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        
        // Get filters from FiltersViewController
        var term: String?
        if !searchBar.text.isEmpty {
            term = searchBar.text
        }
        let sortValue = filters["sort"] as? Int
        var categories = filters["categories"] as? [String]
        var deal = filters["deal"] as? Bool
        var radius = filters["radius"] as! Float?
        if let radiusValue = radius {
            radius = radiusValue * meterConst
        }
        
        // Set filters in this view controller
        self.filters["sort"] = NSNumber(unsignedInteger: sortValue!)
        self.filters["categories"] = categories
        self.filters["deal"] = deal
        self.filters["radius"] = radius
        
        Business.searchWithTerm(term, sort: sortValue, categories: categories, deals: deal, radius: radius, offset: nil) { (result: Result!, error: NSError!) -> Void in
            
            if result != nil {
                self.totalResult = result.total!
                self.businesses = result.businesses
                self.tableView.reloadData()
                self.setTableViewVisible()
                self.createMarkers()
                // println("total: \(result.total)")
                
                // Scroll to the top of table view
                self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
            } else {
                self.totalResult = 0
            }
            
            self.setTableViewVisible()
        }
    }
    
    // MARK: Search bar
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.showsCancelButton = true
        
        let x = searchBar.frame.origin.x
        let y = searchBar.frame.origin.y
        let width = searchBar.frame.width
        let height = searchBar.frame.height
        
        self.navigationController?.navigationBar.bringSubviewToFront(searchBar)
        mapButton.tintColor = UIColor.clearColor()
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.LayoutSubviews, animations: {
            searchBar.frame = CGRect(x: x, y: y, width: width + 50, height: height)
            }, completion: nil)
        
        for view in searchBar.subviews {
            for subView in view.subviews {
                if subView is UITextField {
                    let textField = subView as! UITextField
                    textField.font = UIFont(name: "Helvetica", size: 14)
                }
            }
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = false
        
        let x = searchBar.frame.origin.x
        let y = searchBar.frame.origin.y
        let width = searchBar.frame.width
        let height = searchBar.frame.height
        
        self.navigationController?.navigationBar.bringSubviewToFront(searchBar)
        mapButton.tintColor = UIColor.whiteColor()
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.LayoutSubviews, animations: {
            searchBar.frame = CGRect(x: x, y: y, width: width - 50, height: height)
            }, completion: nil)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        businesses.removeAll(keepCapacity: false)
        tableView.reloadData()
        searchBusisness()
        searchBar.resignFirstResponder()
    }
    
    func searchBusisness() {
        
        var term: String?
        if !searchBar.text.isEmpty {
            term = searchBar.text
        }
        
        let sort = filters["sort"] as? Int
        let categories = self.filters["categories"] as? [String]
        let deal = self.filters["deal"] as? Bool
        let radius = self.filters["radius"] as! Float?
        let offset = businesses.count
        
        Business.searchWithTerm(term, sort: sort, categories: categories, deals: deal, radius: radius, offset: offset) { (result: Result!, error: NSError!) -> Void in
            
            if result != nil {
                self.totalResult = result.total!
                
                if offset < result.total {
                    for b in result.businesses {
                        self.businesses.append(b)
                    }
                }
                self.tableView.reloadData()
                self.createMarkers()
                //println("total: \(result.total)")
            } else {
                self.totalResult = 0
            }
            
            self.setTableViewVisible()
        }
    }
    
    // MARK: Google Map
    
    @IBAction func onMapButton(sender: AnyObject) {
        
        var buttonImg = mapButton.image
        if buttonImg == UIImage(named: "Map") {
            tableView.hidden = true
            mapView.hidden = false
            
            mapButton.image = UIImage(named: "List")
        } else {
            tableView.hidden = false
            mapView.hidden = true
            
            mapButton.image = UIImage(named: "Map")
        }
    }
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        
//        var infoWindow = NSBundle.mainBundle().loadNibNamed("InfoWindow", owner: self, options: nil).first! as! CustomInfoWindow
//        
//        println("view height: \(infoWindow.windowView.frame.height)")
//        
//        infoWindow.layer.cornerRadius = 5
//        infoWindow.layer.borderColor = UIColor(red: 190/255, green: 38/255, blue: 37/255, alpha: 1.0).CGColor
//        infoWindow.layer.borderWidth = 1
//        
//        var (business, index) = getBusinessFromMarker(marker)
//        if business != nil {
//            infoWindow.nameLabel.text = String(index + 1) + ". " + business!.name!
//            infoWindow.distanceLabel.text = business!.distance
//            infoWindow.reviewsCountLabel.text = "\(business!.reviewCount!) Reviews"
//            infoWindow.addressLabel.text = business!.address!
//            infoWindow.categoriesLabel.text = business!.categories!
//            infoWindow.ratingImageView.setImageWithURL(business!.ratingImageURL)
//        }
//        
//        infoWindow.nameLabel.numberOfLines = 0
//        infoWindow.nameLabel.sizeToFit()
//        
//        var viewHeight = 72 + infoWindow.nameLabel.frame.height
//        infoWindow.windowView.frame = CGRect(x: 0, y: 0, width: 250, height: viewHeight)
//        
//        
//        println("view height: \(infoWindow.windowView.frame.height)")
//        
//        infoWindow.frame = CGRect(x: 0, y: 0, width: 250, height: viewHeight)
        
        
        
        var (business, index) = getBusinessFromMarker(marker)
        
        // New info window view
        var darkColor = UIColor(red: 190/255, green: 38/255, blue: 37/255, alpha: 1.0)
        var lightColor = UIColor(red: 220/255, green: 140/255, blue: 140/255, alpha: 1.0)
        
        var infoWindow = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 90))
        infoWindow.layer.backgroundColor = UIColor(red: 250/255, green: 234/255, blue: 234/255, alpha: 1).CGColor
        
        infoWindow.layer.cornerRadius = 5
        infoWindow.layer.borderColor = UIColor(red: 190/255, green: 38/255, blue: 37/255, alpha: 1.0).CGColor
        infoWindow.layer.borderWidth = 1
        
        var nameLabel = UILabel(frame: CGRect(x: 8, y: 8, width: 184, height: 18))
        nameLabel.text = String(index + 1) + ". " + business!.name!
        nameLabel.font = UIFont.boldSystemFontOfSize(14)
        nameLabel.textColor = darkColor
        nameLabel.numberOfLines = 0
        nameLabel.sizeToFit()
        infoWindow.addSubview(nameLabel)
        
        var distanceLabel = UILabel(frame: CGRect(x: 200, y: 8, width: 42, height: 14))
        distanceLabel.text = business!.distance
        distanceLabel.font = UIFont.systemFontOfSize(12)
        distanceLabel.textColor = lightColor
        infoWindow.addSubview(distanceLabel)
        
        var ratingY = nameLabel.bounds.origin.y + nameLabel.frame.height + 12
        var ratingImageView = UIImageView(frame: CGRect(x: 8, y: ratingY, width: 83, height: 15))
        ratingImageView.setImageWithURL(business!.ratingImageURL)
        infoWindow.addSubview(ratingImageView)
        
        var reviewsCountLabel = UILabel(frame: CGRect(x: 99, y: ratingY, width: 78, height: 14))
        reviewsCountLabel.text = "\(business!.reviewCount!) Reviews"
        reviewsCountLabel.font = UIFont.systemFontOfSize(12)
        reviewsCountLabel.textColor = lightColor
        infoWindow.addSubview(reviewsCountLabel)
        
        var priceLabel = UILabel(frame: CGRect(x: 228, y: ratingY, width: 14, height: 14))
        priceLabel.text = "$$"
        priceLabel.font = UIFont.systemFontOfSize(12)
        priceLabel.textColor = lightColor
        infoWindow.addSubview(priceLabel)
        
        var addressY = ratingY + ratingImageView.frame.height + 4
        var addressLabel = UILabel(frame: CGRect(x: 8, y: addressY, width: 234, height: 14))
        addressLabel.text = business!.address!
        addressLabel.font = UIFont.systemFontOfSize(12)
        addressLabel.textColor = darkColor
        addressLabel.numberOfLines = 0
        addressLabel.sizeToFit()
        infoWindow.addSubview(addressLabel)
        
        var categoriesY = addressY + addressLabel.frame.height + 4
        var categoriesLabel = UILabel(frame: CGRect(x: 8, y: categoriesY, width: 234, height: 14))
        categoriesLabel.text = business!.categories!
        categoriesLabel.font = UIFont.systemFontOfSize(12)
        categoriesLabel.textColor = lightColor
        categoriesLabel.numberOfLines = 0
        categoriesLabel.sizeToFit()
        infoWindow.addSubview(categoriesLabel)
        
        var viewHeight = categoriesY + categoriesLabel.frame.height + 8
        infoWindow.frame = CGRect(x: 0, y: 0, width: 250, height: viewHeight)
        
        return infoWindow
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        
        var dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DetailNavC") as! DetailViewController
        var nc = UINavigationController(rootViewController: dvc)
        
        var (business, index) = getBusinessFromMarker(marker)
        dvc.selectedBusiness = business
        self.presentViewController(nc, animated: true, completion: nil)
    }
    
    func createMarkers() {
        
        // Clear all markers before creating new ones
        mapView.clear()
        
        if businesses.count > 0 {
            var camera = GMSCameraPosition.cameraWithLatitude(businesses[0].latitude!, longitude: businesses[0].longitude!, zoom: 15)
            mapView.camera = camera
            mapView.myLocationEnabled = true
            
            // Create maker for each business
            for i in 0..<businesses!.count {
                var marker = GMSMarker()
                marker.position = CLLocationCoordinate2DMake(businesses[i].latitude!, businesses[i].longitude!)
                marker.icon = createMarkerIcon(i + 1)
                marker.map = mapView
            }
        }
    }
    
    func createMarkerIcon(no: Int) -> UIImage {
        
        var markerView = UIView(frame:CGRectMake(0, 0, 50, 50))
        
        //Add icon
        var icon = UIImageView(frame: CGRectMake(0, 0, 50, 50))
        icon.image = UIImage(named: "Marker")
        markerView.addSubview(icon)
        
        //Add Label
        var noLabel = UILabel(frame: CGRectMake(0, 8, 50, 30))
        noLabel.text = String(no)
        noLabel.textAlignment = NSTextAlignment.Center
        noLabel.textColor = UIColor.whiteColor()
        markerView.addSubview(noLabel)
        
        return imageFromView(markerView)
    }
    
    func imageFromView(aView:UIView) -> UIImage {
        
        if(UIScreen.mainScreen().respondsToSelector("scale")) {
            UIGraphicsBeginImageContextWithOptions(aView.frame.size, false, UIScreen.mainScreen().scale)
        }
        else {
            UIGraphicsBeginImageContext(aView.frame.size)
        }
        aView.layer.renderInContext(UIGraphicsGetCurrentContext())
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func getBusinessFromMarker(marker: GMSMarker) -> (Business?, Int) {
        
        var latitude = Double(marker.position.latitude)
        var longitude = Double(marker.position.longitude)
        
        for i in 0..<businesses!.count {
            let businessLatitude = businesses[i].latitude as Double!
            let businessLongitude = businesses[i].longitude as Double!
            if businessLatitude == latitude && businessLongitude == longitude {
                return (businesses[i], i)
            }
        }
        
        return (nil, -1)
    }

}
