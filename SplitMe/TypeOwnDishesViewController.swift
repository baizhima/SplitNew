//
//  TypeOwnDishesViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/15.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit
import Parse

class TypeOwnDishesViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UITableViewDelegate {

    var dishes = [Dish]()
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dishField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var dishTable: UITableView!
    
    func printErrorAndExit(message: String){
        
        print("\(NSStringFromClass(self.classForCoder)): \(message)")
        exit(EXIT_FAILURE)
    }
    
    func removeDishFromCloud(dish: Dish){
        dish.deleteInBackground()
    }
    
    func saveDishFromCloud(dish: Dish){
        dish.saveInBackground()
    }
    
    // fetch dishes and save to dishes object
    func fetchDishesFromCloud(){
        
        if let user = User.currentUser {
            
            let query = Dish.query()
            query?.whereKey("ownBy", equalTo: user)
            query?.whereKey("isShared", equalTo: false)
            query?.findObjectsInBackgroundWithBlock({
                (objects, error ) -> Void in
                if error == nil {
                    
                    self.dishes = objects as! [Dish]
                    self.dishTable.reloadData()
                    
                }else{
                    self.printErrorAndExit("Fail to fetch dishes from server: \(error)")
                }
            })
            
        }
    }
    
    func fetchImageFromCloud(){
        
        if let meal = Meal.currentMeal {
            meal.fetchInBackgroundWithBlock {
                (object, error) -> Void in
                if error != nil{
                    print(error )
                } else {
                    if let url = NSURL(string: meal.image) {
                        if let data = NSData(contentsOfURL: url) {
                            self.imageView.image = UIImage(data: data)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        
        // this back should be removed
        
//        if User.currentUser!.isHost {
//            self.performSegueWithIdentifier("typeOwnDishesToServerWait", sender: self)
//        } else {
//            self.performSegueWithIdentifier("typeOwnDishesToClientJoin", sender: self)
//        }
    }
    
    @IBAction func nextPressed(sender: UIBarButtonItem) {
        
        if let meal = Meal.currentMeal {
            
            if let user = User.currentUser {
                
                // jump to next view
                if user.objectId == meal.master.objectId {
                    self.performSegueWithIdentifier("typeOwnDishesToServerTypeShareDishes", sender: self)
                }else{
                    self.performSegueWithIdentifier("typeOwnDishesToClientWatchAllDishes", sender: self)
                }
            }else{
                printErrorAndExit("Fail to get current user")
            }
        }else{
            printErrorAndExit("Fail to get current meal")
        }

    }
    

    
    @IBAction func addPressed(sender: UIButton) {
        
        // add my own dishes into dish list
        if dishField!.text != "" && priceField!.text != "" {
            // TODO:
            let currDish = Dish(name: dishField.text!, price: Double(priceField.text!)!, isShared: false, meal: Meal.currentMeal!, ownBy: User.currentUser!)
            
            dishes.append(currDish)
            
            saveDishFromCloud(currDish)
            
            dishField.text = ""
            priceField.text = ""
            dishTable.reloadData()
            dishField.becomeFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bgColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1.0)
        //navBar.barTintColor = bgColor
        let statusBarView = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
        )
        statusBarView.backgroundColor = bgColor
        self.view.addSubview(statusBarView)
        
        
        imageView.image = nil
        
        self.scrollView.minimumZoomScale = 1.5
        self.scrollView.maximumZoomScale = 3.0
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        

        fetchImageFromCloud()
        fetchDishesFromCloud()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dishField.resignFirstResponder()
        priceField.resignFirstResponder()
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dishes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        let idx = dishes.count-1-indexPath.row
        newCell.textLabel!.text = "\(dishes[idx].name)"
        newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", dishes[idx].price))
        return newCell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            dishes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
}
