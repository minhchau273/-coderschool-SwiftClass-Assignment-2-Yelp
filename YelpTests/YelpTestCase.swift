//
//  YelpTestCase.swift
//  Yelp
//
//  Created by EastAgile42 on 10/16/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import KIF

class YelpTestCase: KIFTestCase {

    override func beforeEach() {
        super.beforeEach()
        tester.backToBusinessesView()
    }
}
