//
//  ServerConfirmTotalViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/16.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class ServerConfirmTotalViewController: UIViewController {
    
    var subtotal = 0.0
    var tax = 0.0
    var tipsPct: Int?
    var tips = 0.0
    
    
    @IBOutlet weak var subtotalField: UILabel!
    
    @IBOutlet weak var taxField: UITextField!
    
    
    @IBOutlet weak var pickerVIew: UIPickerView!
    
    @IBOutlet weak var totalField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        for dish in currMeal!.shareDishes {
            subtotal += dish.price
        }
        for dish in currMeal!.soloDishes {
            subtotal += dish.price
        }*/
        
        if let meal = Meal.currentMeal {
           
            meal.fetchIfNeededInBackground()
            
            subtotalField.text = "\(meal.subtotal)"
            totalField.text = "\(meal.subtotal)"
        }
        
        //subtotalField.text = "\(subtotal)"
        //totalField.text = "\(subtotal)"
        // Do any additional setup after loading the view.
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
