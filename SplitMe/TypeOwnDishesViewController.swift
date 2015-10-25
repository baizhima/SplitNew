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
       
        for dish: Dish in soloDishArr{
            dish.saveInBackground()
        }
        
        if let meal = Meal.currentMeal {
       
//            meal.fetchIfNeededInBackground()
//            meal.addUniqueObjectsFromArray(soloDishArr, forKey: "dishes")
//            meal.saveInBackground()
//            
            if let user = User.currentUser {
                
                if meal.master.objectId ==  user.objectId {
                    self.performSegueWithIdentifier("typeOwnDishesToServerTypeShareDishes", sender: self)
                } else {
                   
                    user.state = User.DishesSaved
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
        // extend currMeal.soloDishes by dishArr
//        if let meal = Meal.currentMeal {
//            meal.fetchIfNeededInBackground()
//            meal.addUniqueObjectsFromArray(soloDishArr, forKey: "dishes")
//            meal.saveInBackground()
//            
//            if let user = User.currentUser {
//                
//                if meal.master.objectId ==  user.objectId {
//                    self.performSegueWithIdentifier("typeOwnDishesToServerTypeShareDishes", sender: self)
//                } else {
//                    self.performSegueWithIdentifier("typeOwnDishesToClientWatchAllDishes", sender: self)
//                }
//            }else{
//                debugPrint("Error: Current user is nil")
//            }
//        }else{
//            debugPrint("Error: Current meal is nil")
//        }
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
        // TODO:
        imageView.image = nil
        //imageView.image = currMeal?.receiptImage
        self.scrollView.minimumZoomScale = 1.5
        self.scrollView.maximumZoomScale = 3.0
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
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
        return soloDishArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        let idx = soloDishArr.count-1-indexPath.row
        newCell.textLabel!.text = "\(soloDishArr[idx].name)"
        newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", soloDishArr[idx].price))
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
