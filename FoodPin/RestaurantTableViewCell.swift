//
//  RestaurantTableViewCell.swift
//  FoodPin
//
//  Created by Phoenix Wu on H29/09/12.
//  Copyright © 平成29年 Phoenix Wu. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var locationCell: UILabel!
    
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
