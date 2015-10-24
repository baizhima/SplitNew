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
      //  currMeal?.shareDishes.appendContentsOf(sharedDishArr)
        Meal.currentMeal!.addUniqueObjectsFromArray(sharedDishArr, forKey:"sharedDishes")
        Meal.currentMeal!.saveInBackground()
        
        
        self.performSegueWithIdentifier("serverTypeShareDishesToServerCheckSubtotal", sender: self)
        
    }
    
    @IBAction func addPressed(sender: UIButton) {
        if dishField!.text != "" && priceField!.text != "" {
            let currDish = Dish(name: dishField.text!, price: Double(priceField.text!)!, isShared: true)
            
            sharedDishArr.append(currDish)
            print("shareDishArr count = \(sharedDishArr.count)")
            dishField.text = ""
            priceField.text = ""
            dishTable.reloadData()
            dishField.becomeFirstResponder()
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
        let urlStr = Meal.currentMeal!.image
        if let url = NSURL(string: urlStr) {
            if let data = NSData(contentsOfURL: url) {
                imageView.image = UIImage(data: data)
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
