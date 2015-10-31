//
//  ServerWaitViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/15.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit
import Parse

class ServerWaitViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
     {

    var timer: NSTimer?
    
    @IBOutlet var navBar: UINavigationBar!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var joinedFriendsField: UILabel!
    @IBOutlet weak var splitCodeField: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var uploadPromptView: UIView!
    
    
    @IBAction func retakePressed(sender: UIButton) {
        getImage()
    }
    
    
    @IBAction func startPressed(sender: UIButton) {
        
        if let meal: Meal =  Meal.currentMeal {
            do{
                try meal.fetch()
            }
            catch _{
                
            }
            
            if meal.image == nil {
                print("error: image empty")
                return
            }
            if meal.users.count < 2 {
                print("less than one friends joined")
                return
            }
            
            meal.state = Meal.AllUserJoined
            meal.saveInBackground()
            
            if let timer = self.timer {
                timer.invalidate()
            }
            
            self.performSegueWithIdentifier("serverWaitToTypeOwnDishes", sender: self)
            
        } else {
            print("error: current meal is nil")
        }
    }
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("serverWaitToHome", sender: self)
    }
    
    
    func getImage() {
        let imageFromSource = UIImagePickerController()
        imageFromSource.delegate = self
        imageFromSource.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imageFromSource.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            imageFromSource.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        self.presentViewController(imageFromSource, animated: true, completion: nil)
    }
    
    
    
    func fetchMeal(){
        
        if let meal: Meal = Meal.currentMeal {
            
            meal.fetchInBackgroundWithBlock {
                (object, error) -> Void in
                if error != nil{
                    print(error)
                }
                else{
                    if let meal: Meal = object as? Meal{
                        self.joinedFriendsField.text = String(meal.users.count-1)
                    }
                }
            }
            if meal.users.count > 1 && meal.image != nil {
                self.startButton.enabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       /*
        let bgColor = UIColor(red:0.49, green:0.71, blue:0.84, alpha:1.0)
        
        let statusBarView = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 19.8)
        )
        
        statusBarView.backgroundColor = bgColor
        self.view.addSubview(statusBarView)*/
        
        
        
        let uploadSubviewTap = UITapGestureRecognizer.init(target: self, action: Selector("getImage"))
        uploadPromptView.addGestureRecognizer(uploadSubviewTap)
        
        
        
        retakeButton.hidden = true
        startButton.enabled = false
        
        if let meal = Meal.currentMeal{
            splitCodeField.text = meal.code
        }else{
            print("current meal is nil")
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("fetchMeal"), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveImage(image : UIImage){
        
        if let meal: Meal = Meal.currentMeal{
            
            let imageData = UIImageJPEGRepresentation(image, 0.2)
            
            let imageFile = PFFile(name:"image.jpeg", data:imageData!)
            
            imageFile!.saveInBackgroundWithBlock({
                (ok, error) -> Void in
                if( error != nil){
                    print("[ServerWait] Fail to save image to server: \(error)")
                }else{
                    meal.image = imageFile?.url
                    meal.saveInBackgroundWithBlock({
                        (ok, error) -> Void in
                        if(!ok){
                            print("[ServerWait] Fail to save meal to server: \(error)")
                        }
                    })
                }
            })
            
            if meal.users.count > 1 {
                startButton.enabled = true // just for fast response purpose
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
      
        let receiptImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = receiptImage
        self.dismissViewControllerAnimated(true, completion: {})
        
        retakeButton.hidden = false
        uploadPromptView.hidden = true
        saveImage(receiptImage!)
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
