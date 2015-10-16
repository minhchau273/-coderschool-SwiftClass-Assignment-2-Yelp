//
//  SearchFeatureTests.swift
//  Yelp
//
//  Created by EastAgile42 on 10/16/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import KIF

class SearchFeatureTests: YelpTestCase {

    func testNoResultWithFilter() {
        tester.tapFilter()
        tester.setFilter()
        tester.searchNoResultWithFilter()
    }

    func testNoResultWithSearchBar() {
        tester.inputKeyword("zxc")
        tester.searchNoResultWithSearchBar()
    }

}

// MARK: - Test Detail
extension KIFUITestActor {

    func inputKeyword(keyword: String) {
        enterText(keyword, intoViewWithAccessibilityLabel: "Search Bar")
    }

    // MARK: Test No result with search bar
    func searchNoResultWithSearchBar() {
        tapViewWithAccessibilityLabel("search")
        waitForViewWithAccessibilityLabel("No Results Found")
    }

    // MARK: Test No result with filter
    func setFilter() {
        tapViewWithAccessibilityLabel("OfferDeal")
        tapViewWithAccessibilityLabel("Afghan")
    }

    func searchNoResultWithFilter() {
        tapViewWithAccessibilityLabel("Search")
        waitForViewWithAccessibilityLabel("No Results Found")
    }

    
    
}
