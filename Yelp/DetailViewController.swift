//
//  DetailViewController.swift
//  Yelp
//
//  Created by Dave Vo on 9/6/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var reviewCountLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var categoriesLabel: UILabel!
    
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var ratingStarView: UIImageView!
    

    var selectedBusiness: Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = selectedBusiness.name
        nameLabel.text = selectedBusiness.name
        reviewCountLabel.text = "\(selectedBusiness.reviewCount!) Reviews"
        statusLabel.text = selectedBusiness.status
        categoriesLabel.text = selectedBusiness.categories
        phoneLabel.text = selectedBusiness.phone
        distanceLabel.text = selectedBusiness.distance
        addressLabel.text = selectedBusiness.displayAddress
        ratingStarView.setImageWithURL(selectedBusiness.ratingImageURL)
        imageView.setImageWithURL(selectedBusiness.imageURL)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    


}
