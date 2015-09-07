//
//  SwitchCell.swift
//  Yelp
//
//  Created by Dave Vo on 9/3/15.
//  Copyright (c) 2015 Chau Vo. All rights reserved.
//

import UIKit
import SevenSwitch

@objc protocol SwitchCellDelegate {
    optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {
    
    @IBOutlet weak var switchLabel: UILabel!
    
    @IBOutlet weak var switchView: UIView!
    
    var onSwitch: SevenSwitch!
    
    var delegate: SwitchCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        onSwitch = SevenSwitch(frame: CGRect(x: 5, y: 3, width: 45, height: 25))
        
        onSwitch.thumbTintColor = UIColor.whiteColor()
        onSwitch.activeColor =  UIColor.clearColor()
        onSwitch.inactiveColor =  UIColor.clearColor()
        onSwitch.onTintColor =  UIColor(red: 235/255, green: 173/255, blue: 173/255, alpha: 1.0)
        onSwitch.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        onSwitch.shadowColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
        
        switchView.addSubview(onSwitch)
        
        onSwitch.addTarget(self, action: "switchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
      
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchValueChanged() {
        if delegate != nil {
            delegate?.switchCell?(self, didChangeValue: onSwitch.on)
        }
    }

}
