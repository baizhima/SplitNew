//
//  ClientDetailViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/30.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class ClientDetailViewController: UIViewController, UITableViewDelegate {
    
    var dishes: [Dish] = [Dish]()
    var tips : Double = 0.0
    var tax : Double = 0.0
    var totalPayment : Double = 0.0
    var meal : Meal?
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var taxLabel: UILabel!
    
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    func getMyPayment(dish: Dish) -> Double{
        var myprice : Double = dish.price
        if( dish.isShared && dish.sharedWith.count > 0){
            myprice = dish.price / Double(dish.sharedWith.count)
        }
        return myprice
    }
    
    func setTotalLabel(){
        

    
//        var total : Double = 0.0
//        for dish : Dish in dishes {
//            total += getMyPayment(dish)
//        }
        
        totalLabel.text = "$ " + String(NSString(format:"%.2f", (User.currentUser?.payment)!))
        
    }
    
    func fetchMeal(){
        Meal.currentMeal?.fetchInBackgroundWithBlock({ (object, error) -> Void in
            
            self.meal = object as? Meal
            
            self.tableView.reloadData()
        })
    }
    
    func fetchDishes(){
        
        if let meal = Meal.currentMeal {
            
            let query = Dish.query()
            query?.whereKey("meal", equalTo: meal)

            //query?.whereKey("shared", containedIn: <#T##[AnyObject]#>)
            query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil{
                    
                    for d : Dish in objects as! [Dish] {
                        if d.isShared == true {
                            for u : User in d.sharedWith {
                                if u.objectId == User.currentUser?.objectId{
                                    self.dishes.append(d)
                                    break
                                }
                            }
                        }
                        else if d.ownBy.objectId == User.currentUser?.objectId {
                            self.dishes.append(d)
                        }
                    }
                
                    self.tableView.reloadData()
                    
                }
            })
        }
        else{
            debugPrint("Error: current meal is nil")
        }
    }

    @IBAction func backPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("clientDetailToClientPay", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
/*
        let statusBarView = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
        )
        statusBarView.backgroundColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1.0)
        self.view.addSubview(statusBarView)*/
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        setTotalLabel()
        fetchMeal()
        fetchDishes()
        /*
        let myTax = ((User.currentUser?.payment)! / (meal?.total)!) * (meal?.tax)!
        // Do any additional setup after loading the view.
        let myTips = ((User.currentUser?.payment)! / (meal?.total)!) * (meal?.tips)!
        taxLabel.text = "$ " + String(NSString(format:"%.2f", myTax))
        tipsLabel.text = "$ " + String(NSString(format:"%.2f", myTips))
*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //print("Client Detail: dish count: \(self.dishes.count)")
        return self.dishes.count + 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        
        
        if( indexPath.row >= dishes.count ){
            let row = indexPath.row - dishes.count
            
            if self.meal == nil {
                return cell
            }
            
            if row == 0 {
                
                let myTax = ((User.currentUser?.payment)! / (meal?.total)!) * (meal?.tax)!
                
                cell.textLabel!.text = "Tax"
                cell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f/%.2f", myTax , (meal?.tax)!))
                return cell
            }
            else if row == 1 {
                let myTips = ((User.currentUser?.payment)! / (meal?.total)!) * (meal?.tips)!
                
                cell.textLabel!.text = "Tips"
                cell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f/%.2f", myTips , (meal?.tips)!))
                return cell
            }
        }
        
        let dish: Dish = dishes[indexPath.row]
        
        let myprice = getMyPayment(dish)
        
        cell.textLabel!.text = "\(dish.name)"
        cell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f/%.2f", myprice, dish.price))
        let idx = indexPath.row
        if idx % 2 == 0 {
            cell.backgroundColor = UIColor.init(red: 146.0/255, green: 146.0/255, blue: 146.0/255, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.init(red: 113.0/255, green: 113.0/255, blue: 113.0/255, alpha: 1.0)
        }
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        
        return cell
        

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
