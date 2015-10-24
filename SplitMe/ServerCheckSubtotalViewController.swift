//
//  ServerCheckSubtotalViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/16.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit
import Parse

class ServerCheckSubtotalViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var subtotalField: UILabel!
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("serverCheckSubtotalToServerTypeShareDishes", sender: self)
    }
    
    @IBAction func nextPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("serverCheckSubtotalToRemoveDishDidNotEat", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        var subtotal = 0.0
        do {
            try Meal.currentMeal!.fetchIfNeeded()
        } catch _ {
            
        }
        
        
        for dish in Meal.currentMeal!.sharedDishes {
            subtotal += dish.price
        }
        for dish in Meal.currentMeal!.soloDishes {
            subtotal += dish.price
        }
        
        subtotalField.text = String(NSString(format:"%.2f", subtotal))
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Meal.currentMeal!.soloDishes.count + Meal.currentMeal!.sharedDishes.count
    }
    

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        print("indexPath.row=\(indexPath.row), soloCount=\(Meal.currentMeal!.soloDishes.count), shareCount=\(Meal.currentMeal!.sharedDishes.count)")
        if indexPath.row < Meal.currentMeal!.soloDishes.count {
            let idx = indexPath.row
            newCell.textLabel!.text = "\(Meal.currentMeal!.soloDishes[idx].name)"
            newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", Meal.currentMeal!.soloDishes[idx].price))
        } else {
            let idx = indexPath.row - Meal.currentMeal!.soloDishes.count
            newCell.textLabel!.text = "\(Meal.currentMeal!.sharedDishes[idx].name)"
            newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", Meal.currentMeal!.sharedDishes[idx].price))
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
