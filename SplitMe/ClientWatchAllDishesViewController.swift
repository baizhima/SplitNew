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
    
    //@IBOutlet weak var promptLabel: UILabel!
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
                    
                    User.fetchAllInBackground(meal.users, block: { (objects, error) -> Void in
                        
                        if error != nil{
                            print(error)
                        }else{
                            
                            let users: [User] = objects as! [User]
                            for user: User in users {
                                if user.state != User.UserDishesSaved {
                                    return
                                }
                            }
                            
                            // just jump to next view
                            self.updateTimer?.invalidate()
                            self.performSegueWithIdentifier("clientWatchAllDishesToServerCheckSubtotal", sender: self)
                        }
                    })

                }else{
                    
                    meal.fetchInBackgroundWithBlock({ ( object, error) -> Void in
                        if error == nil{
                            if meal.state == Meal.SubtotalConfirmed {
                                
                                self.updateTimer?.invalidate()
                                self.performSegueWithIdentifier("clientWatchAllDishesToRemoveDishesDidNotEat", sender: self)
        
                            }else{
                                
                                User.currentUser?.fetchInBackgroundWithBlock({ (object, error) -> Void in
                                    let user = object as! User
                                    if user.state == User.UserJoined {
                                        self.updateTimer?.invalidate()
                                        
                                        self.backButton.enabled = true
                                        self.confirmButton.enabled = true
                                        self.confirmButton.setTitle("Confirm", forState: UIControlState.Normal)
                                        self.confirmButton.backgroundColor = UIColor(red: 250.0/255, green: 220.0/255, blue: 145.0/255, alpha: 1.0)
                                    }
                                })
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
            
            //promptLabel.hidden = false
            //promptLabel.text = "Waiting for others ..."
            
            confirmButton.setTitle("Waiting for others ...", forState: UIControlState.Normal)
            confirmButton.enabled = false
            
            backButton.enabled = false
            
            confirmButton.backgroundColor = UIColor(red: 195.0/255, green: 195.0/255, blue: 195.0/255, alpha: 1.0)
            
            // for every 3 second
            dispatch_async(dispatch_get_main_queue(), {
                self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            })
        }
    }
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
      
        self.performSegueWithIdentifier("clientWatchAllDishesToTypeOwnDishes", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmButton.layer.shadowColor = UIColor.blackColor().CGColor
        confirmButton.layer.shadowOffset = CGSizeMake(3, 3)
        confirmButton.layer.shadowOpacity = 0.8
        confirmButton.layer.shadowRadius = 0.0
        
        /*
        let statusBarView = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
        )
        statusBarView.backgroundColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1.0)
        self.view.addSubview(statusBarView)
        */
    }
    
    override func viewDidAppear(animated: Bool) {

        //promptLabel.hidden = true
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
        
        if !dishes[idx].isShared {
            newCell.backgroundColor = UIColor.init(red: 113.0/255, green: 113.0/255, blue: 113.0/255, alpha: 1)
            newCell.textLabel?.textColor = UIColor.whiteColor()
            newCell.detailTextLabel?.textColor = UIColor.whiteColor()
        } else {
            newCell.backgroundColor = UIColor.init(red: 250.0/255, green: 220.0/255, blue: 145.0/255, alpha: 1)
            newCell.textLabel?.textColor = UIColor.init(red: 26.0/255, green: 26.0/255, blue: 26.0/255, alpha: 1)
            newCell.detailTextLabel?.textColor = UIColor.init(red: 26.0/255, green: 26.0/255, blue: 26.0/255, alpha: 1)
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
