//
//  ClientJoinViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/15.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit
import Parse

class ClientJoinViewController: UIViewController, UITextFieldDelegate {

    var timer: NSTimer?
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var inputCodeField: UITextField!
    @IBOutlet weak var connectInfo: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("clientJoinToHome", sender: self)
    }
    
    // return true if successfully joint the dinner session
    func joinMeal(slave: User, code: String) -> Bool{
        
        let query = PFQuery(className: Meal.parseClassName())
        query.whereKey("code", equalTo: code)
        query.findObjectsInBackgroundWithBlock {
            (objects, error ) -> Void in
            if error == nil{
                if let meal = objects?.first as? Meal{
                   
                    Meal.currentMeal = meal
                    
                    if meal.state >= Meal.AllUserJoined{
                        self.connectInfo.text = "group closed, sorry"
                        return
                    }
                    
                    slave.state = User.UserJoined
                    slave.saveInBackground()
                    
                    //meal.users.append(slave)
                    meal.addUniqueObject(slave, forKey: "users")
                    
                    meal.saveInBackgroundWithBlock({
                        (success, error ) -> Void in
                        if(success){
                            self.connectInfo.text = "joined successfully! Waiting others.."
                            //self.inputCodeField.enabled = false
                            //self.confirmButton.enabled = false
                            //print(meal)
                        }
                    })
                    self.inputCodeField.enabled = false
                    self.confirmButton.enabled = false
                }else{
                    self.connectInfo.text = "Invalid group code. Try again."
                }
            }else{
                print("query meal error: \(error)")
            }
        }
        return false;
    }
    
    @IBAction func confirmPressed(sender: UIButton) {
        let code = Int(inputCodeField!.text!)!
        if code > 9999 || code < 1000 {
            connectInfo.text = "Code is 4 digits"
            connectInfo.hidden = false
            return
        }
        
        connectInfo.text = "Connecting \(code)..."
        connectInfo.hidden = false
        // connecting
        
        joinMeal(User.currentUser!, code: String(code))

    }
    
    func fetchMeal(){
        
        if let meal: Meal = Meal.currentMeal {
       
            meal.fetchInBackgroundWithBlock {
                (object, error) -> Void in
                if error != nil{
                   print(error )
                }
            }
            
            if meal.state >= Meal.AllUserJoined {
                if let timer = self.timer {
                   timer.invalidate() 
                }
                
                performSegueWithIdentifier("clientJoinToTypeOwnDishes", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectInfo.hidden = true
        
        //self.preferredStatusBarStyle()
        
        let bgColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1.0)
        navBar.barTintColor = bgColor
        let statusBarView = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
        )
        statusBarView.backgroundColor = bgColor
        self.view.addSubview(statusBarView)
        
        
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("fetchMeal"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        inputCodeField.resignFirstResponder()
        
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
