//
//  ClientJoinViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/15.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit
import Parse

class ClientJoinViewController: UIViewController {

    
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
                   
                    meal.users.append(slave)
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
                    print("the result object is not meal \(objects)")
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
                performSegueWithIdentifier("clientJoinToTypeOwnDishes", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectInfo.hidden = true
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("fetchMeal"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
