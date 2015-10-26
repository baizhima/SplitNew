//
//  ClientWatchAllDishesViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/16.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class ClientWatchAllDishesViewController: UIViewController, UITableViewDelegate {
    
    var timer: NSTimer?
    var soloDishes = [Dish]()
    var sharedDishes = [Dish]()
    
    @IBOutlet weak var soloDishesView: UITableView!
    
    @IBOutlet weak var sharedDishesView: UITableView!
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        if let timer = self.timer {
            timer.invalidate()
        }
        
        self.performSegueWithIdentifier("clientWatchAllDishesToTypeOwnDishes", sender: self)
    }

    @IBAction func nextPressed(sender: UIBarButtonItem) {
        /*self.performSegueWithIdentifier("clientWatchAllDishesToRemoveDishesDidNotEat", sender: self)*/
    }
    
    func fetchMeal(){
        
        if let meal: Meal = Meal.currentMeal {
            
            meal.fetchInBackgroundWithBlock {
                (object, error) -> Void in
                if error != nil{
                    print(error )
                }
            }
            
            if meal.state >= Meal.SubtotalConfirmed {
                performSegueWithIdentifier("clientWatchAllDishesToRemoveDishesDidNotEat", sender: self)
            }
            updateSoloDishes()
            updateSharedDishes()
            
            self.soloDishesView.reloadData()
            self.sharedDishesView.reloadData()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("fetchMeal"), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        updateSoloDishes()
        updateSharedDishes()
        self.soloDishesView.reloadData()
        self.sharedDishesView.reloadData()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSoloDishes() {
        
        if let meal = Meal.currentMeal {
            for dish in meal.dishes {
                if !dish.isShared {
                    for user in dish.sharedWith! as [User] {
                        if user.objectId == User.currentUser?.objectId {
                            self.soloDishes.append(dish)
                        }
                    }
                }
            }
        }
    }
    
    func updateSharedDishes() {
        if let meal = Meal.currentMeal {
            for dish in meal.dishes {
                if dish.isShared {
                    self.sharedDishes.append(dish)
                }
            }
        }
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.soloDishesView {
            return self.soloDishes.count
        } else if tableView == self.sharedDishesView {
            return self.sharedDishes.count
        }

        return 2
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        let idx = indexPath.row
        
        if tableView == self.soloDishesView {
            newCell.textLabel!.text = "\(soloDishes[idx].name)"
            newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", soloDishes[idx].price))
        } else if tableView == self.sharedDishesView {
            newCell.textLabel!.text = "\(sharedDishes[idx].name)"
            newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", sharedDishes[idx].price))
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
