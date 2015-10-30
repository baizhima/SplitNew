//
//  ServerTollViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/28.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit

class ServerTollViewController: UIViewController, UITableViewDelegate {

    
    var users: [User]?
    

    @IBOutlet weak var userView: UITableView!
    @IBAction func donePressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("serverTollToHome", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let statusBarView = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
        )
        statusBarView.backgroundColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1.0)
        self.view.addSubview(statusBarView)
    }
    override func viewDidAppear(animated: Bool) {
        if let meal = Meal.currentMeal {
            
            do {
                try meal.fetch()
                try users = User.fetchAll(meal.users) as? [User]
            } catch _ {
                
            }
            userView.reloadData()
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users == nil {
            return 0
        } else {
            return users!.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let newCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        
        if let users = self.users {
            let idx = indexPath.row
            
            newCell.textLabel!.text = "\(users[idx].userName)"
            newCell.detailTextLabel?.text = "$" + String(NSString(format:"%.2f", users[idx].payment))
        }
        
        
        
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
