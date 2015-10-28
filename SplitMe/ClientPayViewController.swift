//
//  ClientPayViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/28.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class ClientPayViewController: UIViewController {

    
    
    @IBOutlet weak var hostNameField: UILabel!
    
    @IBOutlet weak var totalAmountField: UILabel!

    
    @IBAction func donePressed(sender: UIBarButtonItem) {
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        //hostNameField.text = Meal.currentMeal!.master.userName
        let total = 0
        totalAmountField.text = String(NSString(format:"%.2f", total))
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
