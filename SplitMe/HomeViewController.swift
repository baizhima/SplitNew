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
    
    @IBOutlet weak var logoView: UIImageView!
    
    @IBOutlet weak var spliterLabel: UILabel!
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    
    var uiState: Int = 0
    var keyboardOn: Bool = false
    
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
        } else {
            nameField.becomeFirstResponder()
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
        } else {
            nameField.becomeFirstResponder()
        }
    }
    
    
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        viewController.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoView.image = UIImage(named: "logo")
        
        let user = User()
        user.objectId = "EUPUVq6Np4"
        
        let query = Dish.query()
        query?.whereKey("ownBy", equalTo: user)
        query?.whereKey("isShared", equalTo: false)
        query?.findObjectsInBackgroundWithBlock({
            (objects, error ) -> Void in
            if error == nil {
                
                let dishes : [Dish] = objects as! [Dish]
                print(dishes)
                //self.dishTable.reloadData()
                
            }else{
                //self.printErrorAndExit("Fail to fetch dishes from server: \(error)")
            }
        })

        
    }
    
    
    
    override func viewDidLayoutSubviews() {
        
        if uiState < 2 {
            self.spliterLabel.center.y -= self.view.bounds.height
            self.logoView.center.y -= self.view.bounds.height
            
            nameField.center.x -= view.bounds.width
            createButton.center.x -= view.bounds.width
            joinButton.center.x -= view.bounds.width
            uiState += 1
        }
        
        //print("triggered")
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(1, animations: {
            self.spliterLabel.center.y += self.view.bounds.height
            self.logoView.center.y += self.view.bounds.height
            
        })
        
        UIView.animateWithDuration(0.5, delay: 1, options: [], animations: {
            self.nameField.center.x += self.view.bounds.width
            self.createButton.center.x += self.view.bounds.width
            self.joinButton.center.x += self.view.bounds.width
            }, completion: nil)
        //print(nameField.center.x)
    }
    
    
    
    
    
    

    override func didReceiveMemoryWarning() {
        //print("hokadnfkoasdnfkldsankofsodn")
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        self.nameField.frame = CGRect(x: 107,y: 131, width: 100, height: 50)
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameField.resignFirstResponder()
        
        return true
    }
}
