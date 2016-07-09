//
//  DropDownCell.swift
//  Yelp
//
//  Created by Dave Vo on 9/4/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import UIKit

@objc protocol DropDownCellDelegate {
    optional func selectCell(dropDownCell: DropDownCell, didSelect currentImg: UIImage)
}

class DropDownCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var iconView: UIImageView!

    var delegate: DropDownCellDelegate!

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if delegate != nil {
            delegate?.selectCell?(self, didSelect: iconView.image!)
        }
    }
    
}
