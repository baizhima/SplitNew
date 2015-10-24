//
//  Meal.swift
//  ParseStarterProject-Swift
//
//  Created by Sean Hu on 10/16/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import Parse

class Meal: PFObject, PFSubclassing {
    
    static var currentMeal : Meal?
    
    override class func initialize() {
        registerSubclass()
    }
    
    static func parseClassName() -> String{
        return "Meal";
    }
    
    static func generateCode() -> String{
        return String(Int(arc4random_uniform(9000)) + 1000)
    }
    
    @NSManaged var code: String!
    
    @NSManaged var image: String!
   
    @NSManaged var master: User
    @NSManaged var users: [User]
    
    @NSManaged var sharedDishes: [Dish]
    @NSManaged var soloDishes: [Dish]
    
    @NSManaged var tax: Double
    @NSManaged var tips: Double

  
    static let StartUserJoining = 0, AllUserJoined = 1, AllDishesSaved = 2;
    
    @NSManaged var state: Int
    
    override init(){
        super.init()
    }
   
    init(master: User) {
        super.init()
        
        code = Meal.generateCode()
        tax = -1.0
        tips = -1.0
        
        state = Meal.StartUserJoining
        
        self.master = master
        users = [User]()
        users.append(master)
        
        soloDishes = [Dish]()
        sharedDishes = [Dish]()
        
        //image = NilLiteralConvertible
    }
}

