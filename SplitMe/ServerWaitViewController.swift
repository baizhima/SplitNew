//
//  ServerWaitViewController.swift
//  SplitMe
//
//  Created by Shan Lu on 15/10/15.
//  Copyright © 2015年 Shan Lu. All rights reserved.
//

import UIKit
import Parse

class ServerWaitViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var joinedFriendsField: UILabel!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var splitCodeField: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBAction func nextPressed(sender: UIBarButtonItem) {
        // some condition: more than 1 friend, image uploaded ...
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
            
            self.performSegueWithIdentifier("serverWaitToTypeOwnDishes", sender: self)
            
        } else {
            print("error: current meal is nil")
        }
        
    }
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("serverWaitToHome", sender: self)
    }
    
    
    @IBAction func captureImage(sender: UIButton) {
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
            
            meal.fetchInBackgroundWithBlock({
                (object, error) -> Void in
                if error != nil{
                    print(error )
                }
                else{
                    if let meal: Meal = object as? Meal{
                        
                        self.joinedFriendsField.text = String(meal.users.count-1)
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let meal = Meal.currentMeal{
            splitCodeField.text = meal.code
        }else{
            print("current meal is nil")
        }
        
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("fetchMeal"), userInfo: nil, repeats: true)
    }
    
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
      
        let receiptImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = receiptImage
        self.dismissViewControllerAnimated(true, completion: {})
        uploadImageButton.titleLabel!.text = "Retake the photo?"
  
        if let meal: Meal = Meal.currentMeal{
           
            let imageData = UIImageJPEGRepresentation(receiptImage!, 0.2)
            //let imageData = UIImagePNGRepresentation(receiptImag!,
            
            let imageFile = PFFile(name:"image.jpeg", data:imageData!)
            
            imageFile!.saveInBackgroundWithBlock({
                (ok, error) -> Void in
                if( error != nil){
                    print("Can't save image \(error)")
                }else{
                    meal.image = imageFile?.url
                    meal.saveInBackgroundWithBlock({
                        (ok, error) -> Void in
                        if(!ok){
                            print("error when saving meal: \(error)")
                        }
                    })
                }
            })
        }
        

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
