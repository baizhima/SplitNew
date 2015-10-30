//
//  ClientWatchAllDishesViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/16.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit
import Parse

class ClientWatchAllDishesViewController: UIViewController, UITableViewDelegate {
    
    var updateTimer : NSTimer?
    
    var dishes = [Dish]()
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var soloDishesView: UITableView!
    
    
    func fetchDishesFromCloud(){
    
        if let user: User = User.currentUser {
            
            let query = Dish.query()
            query?.whereKey("ownBy" , equalTo: user )
            query?.findObjectsInBackgroundWithBlock({ ( objects, error ) -> Void in
                if error == nil{
                    self.dishes = objects as! [Dish]
                    self.soloDishesView.reloadData()
                }else{
                    
                }
            })
            
        }

    }
    
    
    func update(){
        if let meal = Meal.currentMeal {
            if let myself = User.currentUser{
                
                // for master user
                if meal.master.objectId == myself.objectId {
                    let query = User.query()
                    query?.whereKey("meal", equalTo: meal)
                    query?.findObjectsInBackgroundWithBlock({ (objects, error ) -> Void in
                        if error == nil{
                            
                            let users: [User] = objects as! [User]
                            for user: User in users {
                                if user.state < User.UserDishesSaved {
                                    return
                                }
                            }
                            
                            // just jump to next view
                            self.updateTimer?.invalidate()
                            self.performSegueWithIdentifier("clientWatchAllDishesToServerCheckSubtotal", sender: self)
                            
                        }else{
                        
                        }
                    })

                }else{
                    
                    meal.fetchInBackgroundWithBlock({ ( object, error) -> Void in
                        if error == nil{
                            if meal.state == Meal.SubtotalConfirmed {
                                
                                self.updateTimer?.invalidate()
                                self.performSegueWithIdentifier("clientWatchAllDishesToRemoveDishesDidNotEat", sender: self)
        
                            }else if meal.state == Meal.SubtotalCancelled {
                                
                                self.updateTimer?.invalidate()
                                
                                self.backButton.enabled = true
                                self.confirmButton.enabled = true
                                
                                self.promptLabel.hidden = false
                                self.promptLabel.text = "Please review your dishes"
                                //self.performSegueWithIdentifier("clientWatchAllDishesToTypeOwnDishes", sender: self)
                            }
                        }else{
                            
                        }
                    })
                }
                
            }
        }
    }
    
    @IBAction func confirmPressed(sender: UIButton) {
        
        if let user = User.currentUser {
            
            user.state = User.UserDishesSaved
            user.saveInBackground()
            
            promptLabel.hidden = false
            promptLabel.text = "Waiting for others ..."
            
            confirmButton.enabled = false
            backButton.enabled = false
            
            // for every 3 second
            dispatch_async(dispatch_get_main_queue(), {
                self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            })
        }
    }
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
//        if let timer = self.timer {
//            timer.invalidate()
//        }
        
//        if User.currentUser?.objectId == Meal.currentMeal?.master.objectId {
//            
//        }else{
//            
//        }
        
        self.performSegueWithIdentifier("clientWatchAllDishesToTypeOwnDishes", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        promptLabel.hidden = true
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
//        fetchMeal()
//        dispatch_async(dispatch_get_main_queue(), {
//            self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("fetchMeal"), userInfo: nil, repeats: true)
//        });
        
        fetchDishesFromCloud()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dishes.count
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        let idx = indexPath.row
        
        
            newCell.textLabel!.text = "\(dishes[idx].name)"
            newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", dishes[idx].price))
        
        
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
