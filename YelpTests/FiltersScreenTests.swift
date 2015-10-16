//
//  FiltersScreenTest.swift
//  Yelp
//
//  Created by EastAgile42 on 10/16/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import KIF

class FiltersScreenTests: YelpTestCase {

    func testExpandArea() {
        tester.tapFilter()
        tester.tapAutoToExpandDistanceArea()
        tester.tapBestMatchToExpandSortArea()
        tester.tapSeeAllToExpandCategoryArea()
    }

    func testResetFilters() {
        tester.tapFilter()
        tester.tapAutoToExpandDistanceArea()
        tester.changeDistanceAndReset()
    }

}


// MARK: - Test Detail
extension KIFUITestActor {

    func tapFilter() {
        tapViewWithAccessibilityLabel("Filter")
        waitForViewWithAccessibilityLabel("Filters")
    }

    // MARK: Test expand area
    func tapAutoToExpandDistanceArea() {
        tapViewWithAccessibilityLabel("Auto")
        waitForViewWithAccessibilityLabel("1 mile")
    }

    func tapBestMatchToExpandSortArea() {
        tapViewWithAccessibilityLabel("Best Match")
        waitForViewWithAccessibilityLabel("Distance")
    }

    func tapSeeAllToExpandCategoryArea() {
        tapViewWithAccessibilityLabel("See All")
        waitForViewWithAccessibilityLabel("Vietnamese")
    }

    // MARK: Test reset filters
    func changeDistanceAndReset() {
        tapViewWithAccessibilityLabel("5 miles")
        tapViewWithAccessibilityLabel("Reset filters")
        waitForViewWithAccessibilityLabel("Auto")
    }




    
}
