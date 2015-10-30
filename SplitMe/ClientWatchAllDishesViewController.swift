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
    
    var timer: NSTimer?
    var soloDishes = [Dish]()
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var soloDishesView: UITableView!
    
    
    @IBAction func confirmPressed(sender: UIButton) {
        promptLabel.hidden = false
        confirmButton.enabled = false
        // TODO ...
    }
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        if let timer = self.timer {
            timer.invalidate()
        }
        
        self.performSegueWithIdentifier("clientWatchAllDishesToTypeOwnDishes", sender: self)
    }

    func updateDishes(dishes: [Dish]) {
        
        self.soloDishes = [Dish]()
        for dish in dishes {
            if dish.isShared {
                //self.sharedDishes.append(dish)
            } else {
                if dish.ownBy.objectId == User.currentUser?.objectId {
                    self.soloDishes.append(dish)
                }
                
            }
        }
        
        self.soloDishesView.reloadData()
        
    }
    
    
    
    func fetchMeal(){
        var dishes: [Dish]?
        
        
        if let meal: Meal = Meal.currentMeal {
            meal.fetchInBackgroundWithBlock {
                (object, error) -> Void in
                if error != nil{
                    print(error)
                }
            }
            
            let query = Dish.query()
            query?.whereKey("meal", equalTo: PFObject(withoutDataWithClassName: "Meal", objectId: meal.objectId))
            do{
                try dishes = query?.findObjects() as? [Dish]
                if dishes != nil {
                    self.updateDishes(dishes!)
                }
                    
            }catch _{
                debugPrint("Error in fetching dishes")
            }
 
            
            if meal.state >= Meal.SubtotalConfirmed {
                if let timer = self.timer {
                    timer.invalidate()
                }
                performSegueWithIdentifier("clientWatchAllDishesToRemoveDishesDidNotEat", sender: self)
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        promptLabel.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        fetchMeal()
        dispatch_async(dispatch_get_main_queue(), {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("fetchMeal"), userInfo: nil, repeats: true)
        });
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.soloDishes.count
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        let idx = indexPath.row
        
        
            newCell.textLabel!.text = "\(soloDishes[idx].name)"
            newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", soloDishes[idx].price))
        
        
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
