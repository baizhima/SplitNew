//
//  ClientPayViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/28.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class ClientPayViewController: UIViewController {

    @IBOutlet weak var hostNameField: UILabel!
    @IBOutlet weak var totalAmountField: UILabel!
    
    @IBAction func donePressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("clientPayToHome", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        //hostNameField.text = Meal.currentMeal!.master.userName
        if let meal = Meal.currentMeal {
            meal.fetchInBackgroundWithBlock({ (object , error ) -> Void in
                if error != nil {
                    if let meal: Meal = object as? Meal{
                        self.hostNameField.text = meal.master.userName
                    }
                }
                
            })
            
        }
        if let user = User.currentUser {
            user.fetchInBackgroundWithBlock({
                ( object, error ) -> Void in
                if( error != nil ){
                    debugPrint("Client Pay: fail to fetch user from server")
                }else{
                    self.totalAmountField.text = String(NSString(format:"%.2f", user.payment))
                    
                    debugPrint("Client: should pay \(user.payment)");
                    if let u: User = object as? User  {
                        debugPrint(u)
                    }
                }
            })
            
        }else{
            debugPrint("ClientPay Error: The current user is nil")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
