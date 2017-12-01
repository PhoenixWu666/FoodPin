//
//  Restaurant.swift
//  FoodPin
//
//  Created by Phoenix Wu on H29/09/25.
//  Copyright © 平成29年 Phoenix Wu. All rights reserved.
//

import Foundation

class Restaurant {
    var name = ""
    
    var type = ""
    
    var location = ""
    
    var image = ""
    
    var isVisited = false
    
    var phone = ""
    
    var rating = ""
    
    init(name: String, type: String, location: String, phone: String, image: String, isVisited: Bool) {
        self.name = name
        self.type = type
        self.location = location
        self.phone = phone
        self.image = image
        self.isVisited = isVisited
    }
}
