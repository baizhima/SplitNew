//
//  ClientDetailViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/30.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class ClientDetailViewController: UIViewController {

    @IBAction func backPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("clientDetailToClientPay", sender: self)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBarView = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
        )
        statusBarView.backgroundColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1.0)
        self.view.addSubview(statusBarView)
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
