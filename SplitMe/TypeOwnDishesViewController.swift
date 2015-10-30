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

    var soloDishArr = [Dish]()
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var dishField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
    @IBOutlet weak var dishTable: UITableView!
    
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        if User.currentUser!.isHost {
            self.performSegueWithIdentifier("typeOwnDishesToServerWait", sender: self)
        } else {
            self.performSegueWithIdentifier("typeOwnDishesToClientJoin", sender: self)
        }
    }
    
    @IBAction func nextPressed(sender: UIBarButtonItem) {
        
        if let meal = Meal.currentMeal {
            
            do{
                try meal.fetch()
                
                print(meal)
                
                meal.addUniqueObjectsFromArray(soloDishArr, forKey: "dishes")
                //meal.dishes.appendContentsOf(soloDishArr)
                try Dish.saveAll(soloDishArr)
                try meal.save()
            }catch _{
                debugPrint("fail to save dishes")
            }
            
            if let user = User.currentUser {
                
                if meal.master.objectId ==  user.objectId {
                    user.state = User.SoloDishesSaved
                    user.saveInBackgroundWithBlock({
                        (ok, error) -> Void in
                        if ok {
                            self.performSegueWithIdentifier("typeOwnDishesToServerTypeShareDishes", sender: self)
                        }else{
                            debugPrint(error)
                        }
                    })
                }else {
                   
                    user.state = User.SoloDishesSaved
                    user.saveInBackgroundWithBlock({
                        (ok, error) -> Void in
                        if ok{
                            self.performSegueWithIdentifier("typeOwnDishesToClientWatchAllDishes", sender: self)
                        }else{
                            debugPrint(error)
                        }
                    })
                }
            }else{
                debugPrint("Error: Current user is nil")
            }
        }else{
            debugPrint("Error: Current meal is nil")
        }

    }
    
    @IBAction func addPressed(sender: UIButton) {
        
        // add my own dishes into dish list
        if dishField!.text != "" && priceField!.text != "" {
            // TODO:
            let currDish = Dish(name: dishField.text!, price: Double(priceField.text!)!, isShared: false, meal: Meal.currentMeal!, ownBy: User.currentUser!)
            soloDishArr.append(currDish)
            
            dishField.text = ""
            priceField.text = ""
            dishTable.reloadData()
            dishField.becomeFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bgColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1.0)
        navBar.barTintColor = bgColor
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
        
        // get url from server
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
        return soloDishArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        let idx = soloDishArr.count-1-indexPath.row
        newCell.textLabel!.text = "\(soloDishArr[idx].name)"
        newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", soloDishArr[idx].price))
        return newCell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            soloDishArr.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
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
