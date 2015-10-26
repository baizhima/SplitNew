//
//  ServerConfirmTotalViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/16.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class ServerConfirmTotalViewController: UIViewController {
    
    var dishes: [Dish]?
    
    var subtotal = 0.0
    var tax = 0.0
    var tipsPct: Int?
    var tips = 0.0
    
    
    @IBOutlet weak var subtotalField: UILabel!
    
    @IBOutlet weak var taxField: UITextField!
    
    
    @IBOutlet weak var pickerVIew: UIPickerView!
    
    @IBOutlet weak var totalField: UILabel!
    
    @IBAction func splitPressed(sender: UIButton) {
        
        // TODO modify state code of Meal
        if let meal: Meal =  Meal.currentMeal {
            
            meal.state = Meal.TotalConfirmed
            meal.saveInBackground()
            self.performSegueWithIdentifier("serverConfirmTotalToServerCharge", sender: self)
        }
        
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
        
        self.dishes = fetchDishes()
        
        for dish:Dish in self.dishes! {
            subtotal += dish.price
        }
        
        print("subtotal: \(subtotal)")
        self.subtotalField.text = String(NSString(format:"%.2f", subtotal))
        self.totalField.text = String(NSString(format:"%.2f", (subtotal + tax) * (1 + tips)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
