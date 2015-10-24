//
//  Dinner.swift
//  ParseStarterProject-Swift
//
//  Created by Sean Hu on 10/16/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import Parse

class Dish: PFObject, PFSubclassing{
    
    override class func initialize() {
        registerSubclass()
    }
    
    static func parseClassName() -> String{
        return "Dish";
    }
    
    init(name: String, price: Double, isShared: Bool, ownBy: User) {
        
        super.init(className: Dish.parseClassName())
        
        self.name = name
        self.price = price
        self.isShared = isShared
        self.ownBy = ownBy
        self.sharedWith = nil
    }
    
    @NSManaged var name: String
    @NSManaged var price: Double
    @NSManaged var isShared: Bool
    @NSManaged var ownBy: User
    @NSManaged var sharedWith: [User]?
}
