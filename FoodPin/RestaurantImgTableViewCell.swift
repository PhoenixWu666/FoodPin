//
//  RestaurantImgTableViewCell.swift
//  FoodPin
//
//  Created by Phoenix Wu on H29/09/13.
//  Copyright © 平成29年 Phoenix Wu. All rights reserved.
//

import UIKit

class RestaurantImgTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
