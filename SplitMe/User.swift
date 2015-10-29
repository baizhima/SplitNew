//
//  User.swift
//  ParseStarterProject-Swift
//
//  Created by Sean Hu on 10/16/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import Parse

class User: PFObject, PFSubclassing {
    
    static var currentUser: User?
    
    override class func initialize() {
        registerSubclass()
    }
    
    static func parseClassName() -> String{
        return "User";
    }

    @NSManaged var userName: String
    //@NSManaged var isMaster: Bool    // master or slave
    @NSManaged var image: String?
    
    @NSManaged var isHost: Bool
    
    @NSManaged var payment: Double
    
    static let UserJoining = 0 , UserJoined = 1, SoloDishesSaved = 2, ShareDishesSaved = 3
    
    @NSManaged var state: Int
    
    override init(){
        super.init()
    }
    
    init(userName: String) {
        
        super.init()
        
        self.userName = userName
        self.image = nil
        
        self.isHost = false
        self.state = User.UserJoining
        
        self.payment = 0.0
    }
   
    /*
    static func newSlaveUser(name: String) -> User{
        return User(userName: name, isMaster: false)
    }
        
    static func newMasterUser(name: String) -> User{
        return User(userName: name, isMaster: true)
        
    }*/
    
}
