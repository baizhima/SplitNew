//
//  ServerTypeShareDishesViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/15.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit
import Parse

class ServerTypeShareDishesViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UITableViewDelegate {
    
    var sharedDishArr = [Dish]()
    var timer: NSTimer?
    
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dishField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var dishTable: UITableView!
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("serverTypeShareDishesToTypeOwnDishes", sender: self)
    }
    
    @IBAction func nextPressed(sender: UIBarButtonItem) {
        
       /* for dish in sharedDishArr {
            dish.saveInBackground()
        }*/
        if timer != nil {
            timer?.invalidate()
        }
        self.performSegueWithIdentifier("serverTypeShareDishesToServerCheckSubtotal", sender: self)
        
        
        
    }
    
    @IBAction func addPressed(sender: UIButton) {
        if dishField!.text != "" && priceField!.text != "" {
            
            let price = priceField.text!
            let dishname = dishField.text!
            
            if let user = User.currentUser{
                
                let currDish = Dish(name: dishname, price: Double(price)!, isShared: true, meal: Meal.currentMeal!, ownBy: user)
                
                sharedDishArr.append(currDish)
                print("shareDishArr count = \(sharedDishArr.count)")
                dishField.text = ""
                priceField.text = ""
                dishTable.reloadData()
                dishField.becomeFirstResponder()
                
                currDish.saveInBackground()
            }else{
                print("Error: current user is nil")
            }
        }
    }
    
    func updateMealState() -> Int {
        
        if let meal = Meal.currentMeal {
            
            //do{
                //let users = try User.fetchAll(meal.users) as! [User]
                
                User.fetchAllInBackground(meal.users, block: {(objects: [AnyObject]?, error: NSError?) -> Void in
                    let users = objects as! [User]
                    var count = 0
                    for user: User in users{
                        print("user.state=\(user.state)")
                        if user.state == User.SoloDishesSaved {
                            count += 1
                        }
                    }
                    if( count == users.count ){
                        meal.state = Meal.AllDishesSaved
                    }else{
                        debugPrint("Still \(users.count - count) users didn't finish")
                    }
                    
                    if meal.state == Meal.AllDishesSaved {
                        self.nextButton.enabled = true
                    }
                })
                /*
                var count = 0
                for user: User in users{
                    print("user.state=\(user.state)")
                    if user.state == User.SoloDishesSaved {
                        count += 1
                    }
                }
                if( count == users.count ){
                    meal.state = Meal.AllDishesSaved
                }else{
                    debugPrint("Still \(users.count - count) users didn't finish")
                }*/
                
           /* }catch _ {
                debugPrint("Error: cannot get the number of users who saved meal")
            }*/
            
            
            
        }
        return 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.enabled = false
        
        imageView.image = nil // currMeal?.receiptImage
        self.scrollView.minimumZoomScale = 1.5
        self.scrollView.maximumZoomScale = 3.0
        
    }
    
    override func viewDidAppear(animated: Bool) {
       
        dispatch_async(dispatch_get_main_queue(), {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("updateMealState"), userInfo: nil, repeats: true)
        })
        // get url from server
        if let meal = Meal.currentMeal {
            meal.fetchIfNeededInBackground()
            if let url = NSURL(string: meal.image) {
                if let data = NSData(contentsOfURL: url) {
                    imageView.image = UIImage(data: data)
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
        return sharedDishArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        let idx = sharedDishArr.count-1-indexPath.row
        newCell.textLabel!.text = "\(sharedDishArr[idx].name)"
        newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", sharedDishArr[idx].price))
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
