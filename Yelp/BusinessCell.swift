//
//  BusinessCell.swift
//  Yelp
//
//  Created by Dave Vo on 9/2/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var distanceLabel: UILabel!

    @IBOutlet weak var ratingImageView: UIImageView!

    @IBOutlet weak var reviewsCountLabel: UILabel!

    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var categoriesLabel: UILabel!

    var business: Business! {
        didSet {
            nameLabel.text = business.name
            thumbImageView.setImageWithURL(business.imageURL)
            categoriesLabel.text = business.categories
            addressLabel.text = business.address
            reviewsCountLabel.text = "\(business.reviewCount!) Reviews"
            ratingImageView.setImageWithURL(business.ratingImageURL)
            distanceLabel.text = business.distance
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        thumbImageView.layer.cornerRadius = 3
        thumbImageView.clipsToBounds = true

        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        addressLabel.preferredMaxLayoutWidth = addressLabel.frame.size.width
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        addressLabel.preferredMaxLayoutWidth = addressLabel.frame.size.width
    }

}
