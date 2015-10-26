//
//  HomeViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/15.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit
import Parse



class HomeViewController: UIViewController, UITextFieldDelegate {

    let user = PFObject(className: "User")
    
    @IBOutlet weak var nameField: UITextField!
    @IBAction func createPressed(sender: UIButton) {
        
        if nameField.text!.characters.count > 0 {
            let name = nameField.text!
            let master: User = User(userName: name)
            
            master.saveInBackgroundWithBlock {
                (succeed:Bool, error:NSError?) -> Void in
                if succeed {
                    
                    User.currentUser = master
                    let meal: Meal = Meal(master: master)
                    meal.saveInBackgroundWithBlock {
                        (succeed:Bool, error:NSError?) -> Void in
                        if succeed {
                            //mealId = meal.objectId!
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
        
        if nameField.text!.characters.count > 0 {
            let name = nameField.text!
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameField.resignFirstResponder()
        
        return true
    }
}
