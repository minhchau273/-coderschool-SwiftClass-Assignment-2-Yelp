//
//  Result.swift
//  Yelp
//
//  Created by Dave Vo on 9/5/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import Foundation

class Result: NSObject {
    let total: Int?
    let businesses: [Business]!

    init(total: Int, businesses: [Business]!) {
        self.total = total
        self.businesses = businesses
    }
}