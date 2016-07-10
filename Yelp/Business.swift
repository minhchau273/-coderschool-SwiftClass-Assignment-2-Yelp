//
//  Business.swift
//  Yelp
//
//  Created by Chau Vo on 9/2/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import UIKit
import SwiftString

class Business: NSObject {

    let name: String?
    let address: String?
    let imageURL: NSURL?
    let categories: String?
    let distance: String?
    let ratingImageURL: NSURL?
    let reviewCount: NSNumber?
    let displayAddress: String?
    let status: String?
    let phone: String?
    let latitude: Double?
    let longitude: Double?

    init(dictonary: NSDictionary) {
        name = dictonary["name"] as? String

        let imageURLString = dictonary["image_url"] as? String
        if imageURLString != nil {
            imageURL = NSURL(string: imageURLString!)
        } else {
            imageURL = nil
        }

        let location = dictonary["location"] as? NSDictionary
        var address = ""
        var displayAddress = ""
        var latitude = 0.0
        var longitude = 0.0
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }

            let neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }

            // Get display address
            let displayAddressArray = location!["display_address"] as? NSArray
            if displayAddressArray != nil && displayAddressArray!.count > 0 {
                for s in displayAddressArray! {
                    displayAddress = displayAddress + (s as! String) + ", "
                }
                // Remove ", " at the end
                displayAddress = displayAddress[0..<(displayAddress.characters.count - 2)]
            }

            // Get latitude and longitude
            latitude = (location!.valueForKeyPath("coordinate.latitude") as? Double)!
            longitude = (location!.valueForKeyPath("coordinate.longitude") as? Double)!
        }
        self.address = address
        self.displayAddress = displayAddress
        self.latitude = latitude
        self.longitude = longitude

        let categoriesArray = dictonary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = ", ".join(categoryNames)
        } else {
            categories = nil
        }

        let distanceMeters = dictonary["distance"] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        } else {
            distance = nil
        }

        let ratingImageURLString = dictonary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = NSURL(string: ratingImageURLString!)
        }  else {
            ratingImageURL = nil
        }

        reviewCount = dictonary["review_count"] as? NSNumber

        let isClosed = dictonary["is_closed"] as? Bool
        if let isClosed =  isClosed {
            self.status = isClosed ? "Closed" : "Open"
        } else {
            self.status = "Open"
        }

        let phone = dictonary["phone"] as? String
        var displayPhone = ""
        if let phone = phone {
            if phone.characters.count == 10 {
                displayPhone = "(" + phone.substring(0, length: 3) + ") "
                displayPhone += phone.substring(3, length: 3) + "-"
                displayPhone += phone.substring(6, length: 4)
            } else {
                displayPhone = phone
            }
        } else {
            displayPhone = "N/A"
        }
        self.phone = displayPhone
    }

    class func businesses(array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictonary: dictionary)
            businesses.append(business)
        }
        return businesses
    }

    class func searchWithTerm(term: String?, completion: (Result!, NSError!) -> Void) {
        YelpClient.sharedInstance.searchWithTerm(term, completion: completion)
    }

    class func searchWithTerm(term: String?, sort: Int?, categories: [String]?, deals: Bool?, radius: Float?, offset: Int?, completion: (Result!, NSError!) -> Void) -> Void {
        YelpClient.sharedInstance.searchWithTerm(term, sort: sort, categories: categories, deals: deals, radius: radius, offset: offset, completion: completion)
    }

}
