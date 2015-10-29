//
//  RemoveDishesDidNotEatViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/16.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class RemoveDishesDidNotEatViewController: UIViewController, UITableViewDelegate {

    var timer: NSTimer?
    var sharedDishes : [Dish]?
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    @IBOutlet weak var promptField: UILabel!
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("removeDishesDidNotEatToServerCheckSubTotal", sender: self)
    }
    
    @IBAction func nextPressed(sender: UIBarButtonItem) {
        
        if let meal = Meal.currentMeal {
            if let user = User.currentUser {
                
                do{
                    try sharedDishes = Dish.fetchAllIfNeeded(sharedDishes) as? [Dish]
                }catch _{
                    print("fetch dishes error")
                }
                
                
                // add users to the dishes
                for dish: Dish in sharedDishes! {
                    
                    dish.sharedWith.append(user);
                    dish.saveInBackgroundWithBlock({
                        (ok, error) -> Void in
                        if(!ok){
                            print(error)
                        }
                    })
                }
                
                user.state = User.ShareDishesSaved
                user.saveInBackground()
                
                if meal.master.objectId == user.objectId {
                    self.performSegueWithIdentifier("removeDishesDidNotEatToServerConfirmTotal", sender: self)
                }
                else {
                    promptField.hidden = false
                    nextButton.enabled = false
                }
            }
        }
    }
    
    func fetchSharedDishes() -> [Dish]?{
        
        if let meal = Meal.currentMeal {
            
            let query = Dish.query()
            query?.whereKey("meal", equalTo: meal)
            query?.whereKey("isShared", equalTo: true)
            do{
                try sharedDishes = query?.findObjects() as? [Dish]
                return sharedDishes
            }catch _{
                debugPrint("Error in fetching dishes")
            }
        }else{
            debugPrint("Error: current meal is nil")
        }
        return nil
    }
    
    func updateMealState(){
        
        if let meal: Meal = Meal.currentMeal {
            do {
                try meal.fetch()
            } catch _ {
                
            }
            print("meal.state=\(meal.state)")
            if meal.state == Meal.TotalConfirmed {
                if let timer = self.timer {
                    timer.invalidate()
                }
                self.performSegueWithIdentifier("removeDishesDidNotEatToClientPay", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        promptField.hidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        if Meal.currentMeal!.master.objectId != User.currentUser?.objectId {
            
            dispatch_async(dispatch_get_main_queue(), {
                self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("updateMealState"), userInfo: nil, repeats: true)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sharedDishes == nil{
            self.sharedDishes = fetchSharedDishes()
        }
        
        if let dishes = self.sharedDishes{
            return dishes.count
        }
        else{
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        
        if self.sharedDishes == nil{
            self.sharedDishes = fetchSharedDishes()
        }
        
        if let dishes = self.sharedDishes {
            let dish: Dish = dishes[indexPath.row]
            
            newCell.textLabel!.text = "\(dish.name)"
            newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", dish.price))
        }else{
            debugPrint("Error: tableView: dishes is empty")
        }
        
        return newCell
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
