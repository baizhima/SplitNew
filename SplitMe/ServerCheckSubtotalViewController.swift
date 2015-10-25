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
   
    var dishes: [Dish]?
    
    @IBOutlet weak var subtotalField: UILabel!
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("serverCheckSubtotalToServerTypeShareDishes", sender: self)
    }
    
    @IBAction func nextPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("serverCheckSubtotalToRemoveDishDidNotEat", sender: self)
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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
     
        print("get into view appear")
        
        self.dishes = fetchDishes()
        
        var subtotal = 0.0
        for dish:Dish in dishes! {
            subtotal += dish.price
        }
        
        print("subtotal: \(subtotal)")
        self.subtotalField.text = String(NSString(format:"%.2f", subtotal))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if self.dishes == nil{
            self.dishes = fetchDishes()
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
            self.dishes = fetchDishes()
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
