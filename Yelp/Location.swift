//
//  Location.swift
//  Yelp
//
//  Created by Chau Vo on 9/7/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import Foundation

class Location: NSObject {
    let latitude: Double
    let longitude: Double

    init(lat: Double, lng: Double) {
        self.latitude = lat
        self.longitude = lng
    }
}