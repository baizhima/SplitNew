//
//  HomeViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/15.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit
import Parse

//struct Meal {
//    //let id: UInt32
//    let splitCode: Int
//    var receiptImage: UIImage?
//    let tax: Double
//    let tips: Double
//    var soloDishes: [Dish]
//    var shareDishes: [Dish]
//    let master: User
//    var users: [User]
//    init(splitCode: Int, master: User) {
//        self.splitCode = splitCode
//        receiptImage = nil
//        tax = 0
//        tips = 0
//        soloDishes = [Dish]()
//        shareDishes = [Dish]()
//        self.master = master
//        users = [User]()
//    }
//    
//}
//
//struct User {
//    //let id: UInt32
//    var userName: String
//    var icon: UIImage?
//    var isHost: Bool
//    init() {
//        userName = ""
//        icon = nil
//        isHost = false
//    }
//}
//
//struct Dish {
//    //let id: UInt32
//    var name: String
//    var price: Double
//    var isShared: Bool
//    var users: [User]
//    init(name: String, price: Double, user: User) {
//        self.name = name
//        self.price = price
//        self.isShared = false
//        users = [User]()
//        users.append(user)
//    }
//    init(name: String, price: Double, users: [User]) {
//        self.name = name
//        self.price = price
//        self.isShared = true
//        self.users = [User]()
//        for u in users {
//            self.users.append(u)
//        }
//    }
//}
//
//
//var currUser: User?
var currMeal: Meal?
//
var userId: String = ""
var mealId: String = ""

class HomeViewController: UIViewController {

    let user = PFObject(className: "User")
    
    @IBOutlet weak var nameField: UITextField!
    @IBAction func createPressed(sender: UIButton) {
        
        if let name = nameField.text{
           
            print("before master")
            let master: User = User(userName: name)
            print("after master")
            master.saveInBackgroundWithBlock {
                (succeed:Bool, error:NSError?) -> Void in
                if succeed {
                    
                    print("[Home]userID = \(master.objectId)")
                
                    User.currentUser = master
                    let meal: Meal = Meal(master: master)
                    meal.saveInBackgroundWithBlock {
                        (succeed:Bool, error:NSError?) -> Void in
                        if succeed {
                            mealId = meal.objectId!
                            Meal.currentMeal = meal
                            self.performSegueWithIdentifier("homeToServerWait", sender: self)
                        } else {
                            print(error)
                        }
                    }
                } else {
                    print("create user failed")
                }
            }
        }
    }
    
    @IBAction func joinPressed(sender: UIButton) {
        
        if let name = nameField.text{
           
            let user: User = User(userName: name)
            user.saveInBackgroundWithBlock { (succeed:Bool, error:NSError?) -> Void in
                if succeed {
                    //userId = self.user.objectId!
                    print("[Home]userID = \(user.objectId)")
                   
                    User.currentUser = user
                    
                    self.performSegueWithIdentifier("homeToClientJoin", sender: self)
                } else {
                    print("create user failed")
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
