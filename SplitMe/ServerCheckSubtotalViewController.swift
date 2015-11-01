//
//  ServerCheckSubtotalViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/16.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit
import Parse

class ServerCheckSubtotalViewController: UIViewController, UITableViewDelegate  {
   
    
    var dishes: [Dish]?
    
    @IBOutlet weak var dishesTable: UITableView!
    @IBOutlet weak var subtotalField: UILabel!
    
    
    func fetchDishes(){
        
        if let meal = Meal.currentMeal {
            
            let query = Dish.query()
            query?.whereKey("meal", equalTo: meal)
            query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil{
                    
                    self.dishes = objects as? [Dish]
                    
                    // table view reload
                    self.dishesTable.reloadData()
                    
                    var subtotal = 0.0
                    for dish:Dish in self.dishes! {
                        subtotal += dish.price
                    }
                    
                    print("subtotal: \(subtotal)")
                    meal.subtotal = subtotal
                    self.subtotalField.text = "$ " + String(NSString(format:"%.2f", subtotal))
                    
                }
            })
        }
        else{
            debugPrint("Error: current meal is nil")
        }
    }
    
    func revoke(){
        
        if let meal: Meal =  Meal.currentMeal {
            
            for u : User in meal.users {
                u.state = User.UserJoined
            }
            User.saveAllInBackground(meal.users)
            
            self.performSegueWithIdentifier("serverCheckSubtotalToServerTypeShareDishes", sender: self)
            
            // set all user's state to UserJoin
//            User.fetchAllInBackground(meal.users, block: { (objects, error) -> Void in
//            
//                if error != nil{
//                    print(error )
//                }else{
//                    let users : [User] = objects as! [User]
//                    for u : User in users {
//                        u.state = User.UserJoined
//                    }
//                    User.saveAllInBackground(users)
//                    
//                    self.performSegueWithIdentifier("serverCheckSubtotalToServerTypeShareDishes", sender: self)
//                }
//            })
        }

    }
    
    func confirm(){
        
        if let meal: Meal =  Meal.currentMeal {

            meal.state = Meal.SubtotalConfirmed
            meal.saveInBackground()
            self.performSegueWithIdentifier("serverCheckSubtotalToRemoveDishesDidNotEat", sender: self)
        }

    }
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        revoke()
    }
    
    @IBAction func nextPressed(sender: UIBarButtonItem) {
        confirm()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let statusBarView = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
        )
        statusBarView.backgroundColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1.0)
        self.view.addSubview(statusBarView)
*/
    }
    
    override func viewDidAppear(animated: Bool) {
        
        fetchDishes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if self.dishes == nil{
            return 0;
            //self.dishes = fetchDishes()
        }
      
        if let dishes = self.dishes{
            debugPrint("Dishes count: \(dishes.count)")
            return dishes.count
        }
        else{
            debugPrint("error when checking subtotal: dishes still nil")
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")

        if self.dishes == nil{
            return newCell
            //self.dishes = fetchDishes()
        }
        
        if let dishes = self.dishes {
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
