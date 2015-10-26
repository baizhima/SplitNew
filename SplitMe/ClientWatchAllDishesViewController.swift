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
    var sharedDishes = [Dish]()
    
    @IBOutlet weak var soloDishesView: UITableView!
    
    @IBOutlet weak var sharedDishesView: UITableView!
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        if let timer = self.timer {
            timer.invalidate()
        }
        
        self.performSegueWithIdentifier("clientWatchAllDishesToTypeOwnDishes", sender: self)
    }

    func updateDishes(dishes: [Dish]) {
        self.sharedDishes = [Dish]()
        self.soloDishes = [Dish]()
        for dish in dishes {
            if dish.isShared {
                self.sharedDishes.append(dish)
            } else {
                if dish.ownBy.objectId == User.currentUser?.objectId {
                    self.soloDishes.append(dish)
                }
                
            }
        }
        print("soloDishes.count=\(soloDishes.count), sharedDishes.count=\(sharedDishes.count)")
        self.soloDishesView.reloadData()
        self.sharedDishesView.reloadData()
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
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //dispatch_async(dispatch_get_main_queue(), {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("fetchMeal"), userInfo: nil, repeats: true)
        //});
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
