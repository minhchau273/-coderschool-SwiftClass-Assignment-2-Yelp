//
//  Business.swift
//  Yelp
//
//  Created by Dave Vo on 9/2/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import UIKit

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
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            var street: String? = ""
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            var neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
            
            let displayAddressArray = location!["display_address"] as? NSArray
            if displayAddressArray != nil && displayAddressArray!.count > 0 {
                for s in displayAddressArray! {
                    displayAddress = displayAddress + (s as! String) + ", "
                }
                // Remove ", " at the end
                displayAddress = displayAddress[0..<(count(displayAddress) - 2)]
            }
        }
        self.address = address
        self.displayAddress = displayAddress
        
        let categoriesArray = dictonary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                var categoryName = category[0]
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
            if count(phone) == 10 {
                displayPhone = "(" + phone[0...2] + ") "
                displayPhone += phone[3...5] + "-"
                displayPhone += phone[6...9]
            } else {
                displayPhone = phone
            }
        } else {
            displayPhone = "N/A"
        }
        self.phone = displayPhone
        
    }
    
    class func businesses(#array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            var business = Business(dictonary: dictionary)
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

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
}