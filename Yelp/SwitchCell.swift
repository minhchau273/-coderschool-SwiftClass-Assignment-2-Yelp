//
//  SwitchCell.swift
//  Yelp
//
//  Created by Dave Vo on 9/3/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!

    @IBOutlet weak var switchView: UIView!

    var onSwitch: UISwitch!

    var delegate: SwitchCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()

        onSwitch = UISwitch(frame: CGRect(x: 5, y: 0, width: 45, height: 25))
        onSwitch.onTintColor = UIColor(red: 235/255, green: 173/255, blue: 173/255, alpha: 1.0)
        onSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75)
        switchView.addSubview(onSwitch)

        onSwitch.addTarget(self, action: #selector(SwitchCell.switchValueChanged), forControlEvents: UIControlEvents.ValueChanged)
      
    }

    func switchValueChanged() {
        if delegate != nil {
            delegate?.switchCell?(self, didChangeValue: onSwitch.on)
        }
    }

}
