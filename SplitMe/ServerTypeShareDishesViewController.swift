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
    
    var sharedDishes = [Dish]()
    var timer: NSTimer?
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dishField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var dishTable: UITableView!
    
    @IBOutlet weak var addIconImageView: UIImageView!
    
    func printErrorAndExit(message: String){
        
        print("\(NSStringFromClass(self.classForCoder)): \(message)")
        exit(EXIT_FAILURE)
    }
    
    func saveDishToCloud(dish: Dish){
        dish.saveInBackground()
    }
    
    func removeDishFromCloud(dish: Dish){
        dish.deleteInBackground()
    }
    
    func fetchDishFromCloud(){
        
        if let user = User.currentUser {
            
            let query = Dish.query()
            query?.whereKey("ownBy", equalTo: user)
            query?.whereKey("isShared", equalTo: true)
            query?.findObjectsInBackgroundWithBlock({
                (objects, error ) -> Void in
                if error == nil {
                    
                    self.sharedDishes = objects as! [Dish]
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
        self.performSegueWithIdentifier("serverTypeShareDishesToTypeOwnDishes", sender: self)
    }
    
    @IBAction func nextPressed(sender: UIBarButtonItem) {
        
//        if let meal = Meal.currentMeal {
//            
//            do{
//                try meal.fetchIfNeeded()
//                try Dish.saveAll(sharedDishes)
//                meal.addUniqueObjectsFromArray(sharedDishes, forKey: "dishes")
//                //meal.dishes.appendContentsOf(sharedDishes)
//                try meal.save()
//            }catch _{
//                
//            }
//        }
        
        if timer != nil {
            timer?.invalidate()
        }
        self.performSegueWithIdentifier("serverTypeShareDishesToClientWatchAllDishes", sender: self)
        
    }
    
    func addSharedDish() {
        if dishField!.text != "" && priceField!.text != "" {
            
            let price = priceField.text!
            let dishname = dishField.text!
            
            if let user = User.currentUser{
                
                let currDish = Dish(name: dishname, price: Double(price)!, isShared: true, meal: Meal.currentMeal!, ownBy: user)
                
                sharedDishes.append(currDish)
    
                saveDishToCloud(currDish)
                
                //print("shareDishArr count = \(sharedDishes.count)")
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
    
//    func updateMealState() {
//        
//        if let meal = Meal.currentMeal {
//                
//                User.fetchAllInBackground(meal.users, block: {(objects: [AnyObject]?, error: NSError?) -> Void in
//                    let users = objects as! [User]
//                    var count = 0
//                    for user: User in users{
//                        print("user.state=\(user.state)")
//                        if user.state == User.SoloDishesSaved {
//                            count += 1
//                        }
//                    }
//                    if( count == users.count ){
//                        meal.state = Meal.AllDishesSaved
//                    }else{
//                        debugPrint("Still \(users.count - count) users didn't finish")
//                    }
//                    
//                    if meal.state == Meal.AllDishesSaved {
//                        self.nextButton.enabled = true
//                    }
//                    meal.saveInBackground()
//                })
//        }
//        
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //nextButton.enabled = false
        
        imageView.image = nil // currMeal?.receiptImage
        self.scrollView.minimumZoomScale = 1.5
        self.scrollView.maximumZoomScale = 3.0

        let addTap = UITapGestureRecognizer.init(target: self, action: Selector("addSharedDish"))
        addTap.numberOfTapsRequired = 1
        addIconImageView.userInteractionEnabled = true
        addIconImageView.addGestureRecognizer(addTap)
        
        
        let statusBarView = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
        )
        statusBarView.backgroundColor = UIColor(red:77/255.0, green:77/255.0, blue:77/255.0, alpha:1.0)
        self.view.addSubview(statusBarView)
        
    }
    
    override func viewDidAppear(animated: Bool) {
       
//        dispatch_async(dispatch_get_main_queue(), {
//        self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("updateMealState"), userInfo: nil, repeats: true)
//        })
        
        fetchImageFromCloud()
        fetchDishFromCloud()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touchesBegan")
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        dishField.resignFirstResponder()
        priceField.resignFirstResponder()
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedDishes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        let idx = sharedDishes.count-1-indexPath.row
        newCell.textLabel!.text = "\(sharedDishes[idx].name)"
        newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", sharedDishes[idx].price))
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
