//
//  KIF+SwiftExtension.swift
//  Yelp
//
//  Created by EastAgile42 on 10/16/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import KIF

extension XCTestCase {

  var tester: KIFUITestActor { return tester() }
  var system: KIFSystemTestActor { return system() }


  private func tester(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFUITestActor {
    return KIFUITestActor(inFile: file, atLine: line, delegate: self)
  }

  private func system(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFSystemTestActor {
    return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
  }
}

extension KIFUITestActor {

    func backToBusinessesView() {
        let navigationVC = UIApplication.sharedApplication().delegate?.window??.rootViewController as? UINavigationController
        if let topVC = navigationVC?.topViewController {
            topVC.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
        }
        navigationVC?.popToRootViewControllerAnimated(false)
    }
}