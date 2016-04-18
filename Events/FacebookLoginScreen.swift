//
//  FacebookLoginScreen.swift
//  Events
//
//  Created by Harsha Cuttari on 1/21/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import ParseUI
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4

class FacebookLoginScreen: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func facebookSignInButton(sender: AnyObject) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email"], block: {(user: PFUser?, error: NSError?) ->Void in
            
            // Checking if there is an error during sign up, then prompting user with the error message.
            if (error != nil){
                self.presentViewController(displayErrorMessage(error!), animated:true, completion: nil)
                return
            }
            
            
            // Getting data from the user and uploading it to our parse account
            if (FBSDKAccessToken.currentAccessToken() != nil){
                
                let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,first_name,last_name,picture,email"])
                graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
                    if error != nil {
                        self.presentViewController(displayErrorMessage(error!), animated:true, completion: nil)
                        return
                    } else if (user!.isNew) {
                        user!["firstName"] = result["first_name"] as! String
                        user!["lastName"] = result["last_name"] as! String
                        user!["email"] = result["email"] as! String
                        
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                            //Get Profile Picture
                            let id = result["id"] as! String
                            let userProfile = "https://graph.facebook.com/" + id + "/picture?type=normal"
                            let picUrl = NSURL(string: userProfile)
                            let data = NSData(contentsOfURL: picUrl!)
                            if(data != nil){
                                let pfobj = PFFile(data: data!)
                                print(pfobj)
                                user!["profilePicture"] = pfobj
                            }
                            user!.saveInBackground()
                        }
                        
                    }
                }
            }
            

            let protectedPage = self.storyboard?.instantiateViewControllerWithIdentifier("ProtectedPage") as! ProtectedPage
                    
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    
            appDelegate.window?.rootViewController = protectedPage
            
        })
    }


    
    

}
