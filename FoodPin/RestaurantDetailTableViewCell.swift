//
//  RestaurantDetailTableViewCell.swift
//  FoodPin
//
//  Created by Phoenix Wu on H29/09/28.
//  Copyright © 平成29年 Phoenix Wu. All rights reserved.
//

import UIKit

class RestaurantDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fieldLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
