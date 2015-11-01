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
    
    var animationOffset : CGFloat = 100.0
    
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
        logoView.image = UIImage(named: "shadow_logo")
        
        createButton.layer.shadowColor = UIColor.blackColor().CGColor
        createButton.layer.shadowOffset = CGSizeMake(3, 3)
        createButton.layer.shadowOpacity = 0.8
        createButton.layer.shadowRadius = 0.0
        
        joinButton.layer.shadowColor = UIColor.blackColor().CGColor
        joinButton.layer.shadowOffset = CGSizeMake(3, 3)
        joinButton.layer.shadowOpacity = 0.8
        joinButton.layer.shadowRadius = 0.0
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
    }
    
    
    
//    override func viewDidLayoutSubviews() {
//        
//        if uiState < 2 {
//            self.spliterLabel.center.y -= self.view.bounds.height
//            self.logoView.center.y -= self.view.bounds.height
//            
//            nameField.center.y -= view.bounds.height
//            createButton.center.y -= view.bounds.height
//            joinButton.center.y -= view.bounds.height
//            uiState += 1
//        }
//    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        animationOffset = logoView.center.y - logoView.frame.height/2 - 20.0
        
        
//        UIView.animateWithDuration(1, animations: {
//            self.spliterLabel.center.y += self.view.bounds.height
//            self.logoView.center.y += self.view.bounds.height
//            self.nameField.center.y += self.view.bounds.height
//            self.createButton.center.y += self.view.bounds.height
//            self.joinButton.center.y += self.view.bounds.height
//            
//        })
        
        
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
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= animationOffset
    }
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += animationOffset
    }
}
