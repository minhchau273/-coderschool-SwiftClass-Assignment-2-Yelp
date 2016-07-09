//
//  YelpClient.swift
//  Yelp
//
//  Created by Dave Vo on 9/2/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let yelpConsumerKey = "5PEogcKnmorm48om9FHlTw"
let yelpConsumerSecret = "mTPPMC3KoGdbllzxP7nWcTiR2IQ"
let yelpToken = "Y1y7BQHc_8h9lI7qtEIIHyT8ZGnxf4JR"
let yelpTokenSecret = "wwdiV0wZ98U4wSKgQcm89Mj0ljs"

enum YelpSortMode: Int {
    case BestMatched = 0, Distance, HighestRated
}

class YelpClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!

    class var sharedInstance: YelpClient {
        struct Static {
            static var token: dispatch_once_t = 0
            static var instance: YelpClient? = nil
        }

        dispatch_once(&Static.token) {
            Static.instance = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        }
        return Static.instance!
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        var baseUrl = NSURL(string: "http://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret)

        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }

    func searchWithTerm(term: String?, completion: (Result!, NSError!) -> Void) -> AFHTTPRequestOperation {
        return searchWithTerm(term, sort: nil, categories: nil, deals: nil, radius: nil, offset: nil, completion: completion)
    }

    func searchWithTerm(term: String?, sort: Int?, categories: [String]?, deals: Bool?, radius: Float?, offset: Int?, completion: (Result!, NSError!) -> Void) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api

        // Default the location to San Francisco
        var parameters: [String : AnyObject] = ["ll": "37.785771,-122.406165"]

        if term != nil {
            parameters["term"] = term!
        }

        if sort != nil {
            // parameters["sort"] = sort!.rawValue
            parameters["sort"] = sort!
        }

        if categories != nil && categories!.count > 0 {
            parameters["category_filter"] = categories?.joinWithSeparator(",")
        }

        if deals != nil {
            parameters["deals_filter"] = deals!
        }

        if radius != nil {
            parameters["radius_filter"] = radius!
        }

        if offset != nil {
            parameters["offset"] = offset!
        }

        print(parameters)

        return self.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            var total = response["total"] as? Int
            var dictionaries = response["businesses"] as? [NSDictionary]
            if dictionaries != nil {
                let result = Result(total: total!, businesses: Business.businesses(dictionaries!))
                //                completion(Business.businesses(array: dictionaries!), nil)
                completion(result, nil)
            }
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(nil, error)
        })
    }
    
}