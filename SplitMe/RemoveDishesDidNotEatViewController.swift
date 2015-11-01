//
//  RemoveDishesDidNotEatViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/16.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class RemoveDishesDidNotEatViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var timer: NSTimer?
    var sharedDishes : [Dish] = [Dish]()
    var isRemoved : [Bool] = [Bool]()
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var promptField: UILabel!
    
    
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
            
            User.currentUser?.fetchInBackgroundWithBlock({ (object, error ) -> Void in
                let user = object as! User
                if user.state == User.UserDishesSaved {
                    self.promptField.hidden = true
                    self.nextButton.enabled = true
                }
            })
        }
    }
    
    @IBAction func nextPressed(sender: UIBarButtonItem) {
        
        if let meal = Meal.currentMeal {
            if let user = User.currentUser {
                //print(sharedDishes)
                // add users to the dishes
                for var i=0; i < sharedDishes.count; i++ {
                    
                    if isRemoved[i] == false {
                        sharedDishes[i].addUniqueObject(user, forKey: "sharedWith")
                    }else{
                        sharedDishes[i].removeObject(user, forKey: "sharedWith")
                    }
                    sharedDishes[i].saveInBackground()
                }
          
                user.state = User.UserSharedDishesRemoved
                user.saveInBackground()
                
                if meal.master.objectId == user.objectId {
                    self.performSegueWithIdentifier("removeDishesDidNotEatToServerConfirmTotal", sender: self)
                }
                else {
                    promptField.hidden = false
                    nextButton.enabled = false
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("updateMealState"), userInfo: nil, repeats: true)
                    })
                }
            }
        }
    }
    
    func fetchSharedDishes() {
        
        if let meal = Meal.currentMeal {
            
            let query = Dish.query()
            query?.whereKey("meal", equalTo: meal)
            query?.whereKey("isShared", equalTo: true)
            query?.findObjectsInBackgroundWithBlock({ ( objects, error) -> Void in
                
                if error != nil {
                    print(error)
                }else{
                    self.sharedDishes = objects as! [Dish]
                    self.isRemoved = [Bool](count: self.sharedDishes.count, repeatedValue: false)
                    self.tableView.reloadData()
                }
            })

        }else{
            debugPrint("Error: current meal is nil")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        promptField.hidden = true
        /*
        let statusBarView = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
        )
        statusBarView.backgroundColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1.0)
        self.view.addSubview(statusBarView)
*/
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {

        let meal = Meal()
        meal.objectId = "ASTM1ocNga"
        
        let user = User()
        user.objectId = "CLa2Wm2sQY"
        do{
            try Meal.currentMeal = meal.fetch()
            try User.currentUser = user.fetch()
        }catch _{
            
        }
        print(Meal.currentMeal)
        print(User.currentUser)
        fetchSharedDishes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sharedDishes.count
    }
    
    func actionPressed(sender: UIButton!){
        print("action pressed")
        print(sender)
        
        
        if isRemoved[sender.tag] == true {
            
            isRemoved[sender.tag] = false
            sender.setTitle("+", forState: UIControlState.Normal)
            tableView.reloadData()
            
        }else{
            isRemoved[sender.tag] = true
            sender.setTitle("-", forState: UIControlState.Normal)
            tableView.reloadData()
        }

        //tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DishTableCell", forIndexPath: indexPath) as! DishTableCell
        
        //let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        
        let dish: Dish = self.sharedDishes[indexPath.row]
        
        cell.nameLabel.text = "\(dish.name)"
        cell.priceLabel.text = "$" + String(NSString(format:"%.2f", dish.price))
        
        newCell.backgroundColor = UIColor(red:250.0/255, green:220/255.0, blue:145/255.0, alpha:1.0)
        newCell.textLabel?.textColor = UIColor.whiteColor()
        newCell.detailTextLabel?.textColor = UIColor.whiteColor()
        
        if isRemoved[indexPath.row] == true {
            cell.backgroundColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1.0)
            
            cell.button.setTitle("+", forState: UIControlState.Normal)
        }else{
            
            cell.backgroundColor = UIColor(red:1.0, green:1.0, blue: 1.0, alpha:1.0)
            
            cell.button.setTitle("-", forState: UIControlState.Normal)
        }
        cell.button.tag = indexPath.row
        cell.button.addTarget(self, action: Selector("actionPressed:"), forControlEvents: .TouchUpInside)
        
//        cell.actionImage.tag = indexPath.row
//        cell.actionImage.addGestureRecognizer(UIGestureRecognizer(target: self, action: Selector("actionPressed")))
    
        return cell
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            isRemoved[indexPath.row] = true
            tableView.reloadData()
            //sharedDishes!.removeAtIndex(indexPath.row)
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }

}
