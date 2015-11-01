//
//  ServerConfirmTotalViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/16.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class ServerConfirmTotalViewController: UIViewController, UITextFieldDelegate,
 UIPickerViewDelegate, UIPickerViewDataSource {
    
    var timer: NSTimer?
    var dishes: [Dish]?
    var pickerData: [String] = ["0", "10", "11", "12","13", "14", "15", "16", "17", "18", "19", "20"]
    
    var subtotal = 0.0
    var tax = 0.0
    var tipsPct = 0
    
    
    @IBOutlet weak var subtotalField: UILabel!
    
    @IBOutlet weak var taxField: UITextField!
    
    @IBOutlet weak var pickerVIew: UIPickerView!
    
    @IBOutlet weak var totalField: UILabel!
    
    @IBOutlet weak var splitButton: UIButton!
    
    // xueyang changed
    // when user pressed back
    func revoke() {
        
        // save tax and tips in meal
        
        //Meal.currentMeal?.tax = tax
        //Meal.currentMeal?.tips = tipsPct
        let users = Meal.currentMeal?.users
        for u: User in users! {
            u.state = User.UserDishesSaved
        }
        User.saveAllInBackground(users)
        
//        User.fetchAllInBackground(Meal.currentMeal?.users) { (objects, error) -> Void in
//            if error != nil {
//                print(error)
//                let users = objects as! [User]
//                for u: User in objects as! [User] {
//                    u.state = User.UserJoined
//                    
//                }
//                User.saveAllInBackground(users)
//            }
//        }
//        Meal.currentMeal?.saveInBackground()
        
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        revoke()
        self.performSegueWithIdentifier("ServerConfirmTotalToRemoveDishesDidNotEat", sender: self)
    }
    
    func getSubPayment(user: User, dishes: [Dish]) -> Double{
        
        var sum = 0.0
        for dish: Dish in dishes {
            if( dish.ownBy.objectId == user.objectId && dish.isShared == false){
                sum += dish.price
            }

            for u in dish.sharedWith{
                if u.objectId == user.objectId{
                    sum += dish.price / Double(dish.sharedWith.count)
                }
            }
        }
        return sum;
    }
    
    
    func split(){
        let meal : Meal = Meal.currentMeal!
        var dishes: [Dish]?
        
        let query = Dish.query()
        query?.whereKey("meal", equalTo: meal)
        do{
            try dishes = query?.findObjects() as? [Dish]
            
        }catch _{
            debugPrint("Error in fetching dishes")
        }
        
        for user: User in meal.users {
            
            let subpayment = getSubPayment(user, dishes: dishes!)
            
            // split tax and tips by the number of users
            user.payment = subpayment + (meal.tips + meal.tax)/Double(meal.users.count)
            
            // split tax and tips by the sub total of each user
            //user.payment = meal.total * (subpayment/meal.subtotal);
            
            debugPrint("user: \(user.userName) payment is \(user.payment)" )
        }
        
        User.saveAllInBackground(meal.users)
        
        meal.state = Meal.TotalConfirmed
        meal.saveInBackground()
        
    }
    
    @IBAction func splitPressed(sender: UIButton) {
        
        // TODO modify state code of Meal
        if let meal: Meal =  Meal.currentMeal {
            
            // query for the number of users who confirmed
            User.fetchAllInBackground(meal.users, block: { (objects, error) -> Void in
                if error != nil {
                    print(error)
                }else{
                    let users = objects as! [User]
                    
                    var count = users.count
                    for user : User in users {
                        if user.state == User.UserSharedDishesRemoved {
                            count -= 1
                        }
                    }
                    if count == 0 {
                        self.split()
                        self.performSegueWithIdentifier("serverConfirmTotalToServerToll", sender: self)
                    }else{
                        print("\(count) friends haven't finish ...")
                        
                    }
                }
            })
 
        }
        
    }
    
    func fetchDishes() -> [Dish]?{
        
        if let meal = Meal.currentMeal {
            
            let query = Dish.query()
            query?.whereKey("meal", equalTo: meal)
            do{
                try dishes = query?.findObjects() as? [Dish]
                return dishes
            }catch _{
                debugPrint("Error in fetching dishes")
            }
        }else{
            debugPrint("Error: current meal is nil")
        }
        return nil
    }
    
    func updateTotal() {
        let total: Double = subtotal * (1 + Double(tipsPct) * 1.0 / 100) + tax
        self.totalField.text = String(NSString(format:"%.2f", total))
        if let meal = Meal.currentMeal {
            meal.subtotal = subtotal
            meal.tax = tax
            meal.tips = subtotal * Double(tipsPct) / 100
            meal.total = total
            meal.saveInBackground()
        }
        
    }
    
//    func updateMealState() {
//        
//        if let meal = Meal.currentMeal {
//            
//            
//            User.fetchAllInBackground(meal.users, block: {(objects: [AnyObject]?, error: NSError?) -> Void in
//                let users = objects as! [User]
//                var count = 0
//                for user: User in users{
//                    //print("[ServerConfirmTotal]user.state=\(user.state)")
//                    if user.state == User.ShareDishesSaved {
//                        count += 1
//                    }
//                }
//                if( count == users.count ){
//                    meal.state = Meal.SharedDishesConfirmed
//                }else{
//                    debugPrint("Still \(users.count - count) users didn't finish")
//                }
//                
//                if meal.state == Meal.SharedDishesConfirmed {
//                    self.splitButton.enabled = true
//                }
//            })
//            meal.saveInBackground()
//        }
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //splitButton.enabled = false
        
//        let statusBarView = UIView(frame:
//            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
//        )
//        statusBarView.backgroundColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1.0)
//        self.view.addSubview(statusBarView)
        
        pickerVIew.selectRow(0, inComponent: 0, animated: true)
        
        splitButton.layer.shadowColor = UIColor.blackColor().CGColor
        splitButton.layer.shadowOffset = CGSizeMake(3, 3)
        splitButton.layer.shadowOpacity = 0.8
        splitButton.layer.shadowRadius = 0.0
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
//        dispatch_async(dispatch_get_main_queue(), {
//            self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("updateMealState"), userInfo: nil, repeats: true)
//        })
        
//        self.dishes = fetchDishes()
//        for dish:Dish in self.dishes! {
//            subtotal += dish.price
//        }
        
        self.subtotal = (Meal.currentMeal?.subtotal)!
        
        print("subtotal: \(Meal.currentMeal!.subtotal)")
        self.subtotalField.text = String(NSString(format:"%.2f", subtotal))
        updateTotal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
   /* // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }*/
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = pickerData[row]
        let color = UIColor.whiteColor()
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:color])
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        self.tipsPct = Int(pickerData[row])!
        updateTotal()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if taxField.text!.characters.count > 0 {
            self.tax = Double(taxField.text!)!
        }
        updateTotal()
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        taxField.resignFirstResponder()
        if taxField.text!.characters.count > 0 {
            self.tax = Double(taxField.text!)!
        }
        updateTotal()
        
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
