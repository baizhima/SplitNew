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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dishField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var dishTable: UITableView!
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("serverTypeShareDishesToTypeOwnDishes", sender: self)
    }
    
    @IBAction func nextPressed(sender: UIBarButtonItem) {
        
        for dish in sharedDishArr {
            dish.saveInBackground()
        }
        
        if let user = User.currentUser {
            if let meal = Meal.currentMeal {
           
                if user.state < User.DishesSaved {
                    user.state = User.DishesSaved
                    do{
                        try user.save()
                    }catch _{
                        debugPrint("Error: can't save user to server")
                    }
                }
                
               
                do{
                    
                    let users = try User.fetchAll(meal.users) as! [User]
                    
                    var count = 0
                    for user: User in users{
                        if user.state >= User.DishesSaved {
                            count += 1
                        }
                    }
                    if( count == users.count ){
                        self.performSegueWithIdentifier("serverTypeShareDishesToServerCheckSubtotal", sender: self)
                    }else{
                        debugPrint("Still \(users.count - count) users didn't finish")
                    }
                    
                }catch _ {
                    debugPrint("Error: cannot get the number of users who saved meal")
                }
//              
//                let query = User.query()
//                query?.whereKey("meal", equalTo: meal)
//                query?.whereKey("state", greaterThanOrEqualTo: User.DishesSaved)
//               
//                do{
//                    let users: [User] = try query?.findObjects() as! [User]
//                   
                
            }
        }
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
            }else{
                print("Error: current user is nil")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // XXX: TODO: set to image
        imageView.image = nil // currMeal?.receiptImage
        self.scrollView.minimumZoomScale = 1.5
        self.scrollView.maximumZoomScale = 3.0
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
       
        /*
        let urlStr = Meal.currentMeal!.image
        if let url = NSURL(string: urlStr) {
            if let data = NSData(contentsOfURL: url) {
                imageView.image = UIImage(data: data)
            }
        }*/
        
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
