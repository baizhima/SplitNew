//
//  ServerConfirmTotalViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/16.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class ServerConfirmTotalViewController: UIViewController, UITextFieldDelegate,
 UIPickerViewDelegate, UIPickerViewDataSource {
    
    var dishes: [Dish]?
    var pickerData: [String] = ["0", "10", "11", "12","13", "14", "15", "16", "17", "18", "19", "20"]
    
    var subtotal = 0.0
    var tax = 0.0
    var tipsPct = 0
    
    
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
    
    func updateTotal() {
        let total: Double = (subtotal + tax) * (1 + Double(tipsPct) * 1.0 / 100)
        self.totalField.text = String(NSString(format:"%.2f", total))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerVIew.selectRow(0, inComponent: 0, animated: true)
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        
        self.dishes = fetchDishes()
        
        for dish:Dish in self.dishes! {
            subtotal += dish.price
        }
        
        print("subtotal: \(subtotal)")
        self.subtotalField.text = String(NSString(format:"%.2f", subtotal))
        updateTotal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        self.tipsPct = Int(pickerData[row])!
        updateTotal()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if taxField.text!.characters.count > 0 {
            self.tax = Double(taxField.text!)!
        }
        updateTotal()
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        taxField.resignFirstResponder()
        if taxField.text!.characters.count > 0 {
            self.tax = Double(taxField.text!)!
        }
        updateTotal()
        
        return true
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
