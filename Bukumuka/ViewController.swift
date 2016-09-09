//
//  ViewController.swift
//  Bukumuka
//
//  Created by Nicole on 05/09/2016.
//  Copyright © 2016 Loong. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class ViewController: UIViewController
//,FBSDKLoginButtonDelegate
{
 
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if KeychainWrapper.stringForKey(KEY_UID) != nil {
            print("LOONG: ID Found. Loading Main.")
            enterMain()
        }
    }
    
    @IBAction func fbBtnPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"]) { (result, error) in
            
            if error != nil {
                print("LOONG: Facebook login failed. Error \(error)")
            } else if result?.isCancelled == true {
                print("LOONG: User cancelled Facebook authentication")
                
            } else {
                print("LOONG: Successfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                    self.firebaseAuthenticate(credential)
                

                    }
                }
                
            }
    

    

func showErrorAlert(title: String, msg:String) {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
    let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
}

func firebaseAuthenticate(credential: FIRAuthCredential) {
    FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
        if error != nil {
            print("LOONG: Unable to authenticate with Firebase - \(error)")
        } else {
            print("LOONG: Successfully authenticate with Firebase")
            if let user = user {
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = "blank"
                changeRequest.photoURL = NSURL(string:"blank")
                changeRequest.commitChangesWithCompletion({ (error) in
                    if let error = error {
                        print("error1")
                    } else {
                        print("profile updated")
                        let userData: Dictionary<String,AnyObject> = [
                            "provider": credential.provider,
                            "displayName": user.displayName!,
                            "displayPicIdentifier": user.photoURL!.absoluteString
                        ]
                        print("profile saved")
                        self.completeSignIn(user.uid, userData: userData)
                        //                          self.enterMain()
                        self.newUser()
                    }
                })
                
            }
//            if let user = user {
//                let userData = ["provider": credential.provider]
//                self.completeSignIn(user.uid, userData: userData)
//                self.enterMain()
//            }
        }
    })
}


func enterMain() {
        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)

    }

func newUser() {
        self.performSegueWithIdentifier(SEGUE_LOGGED_IN_FIRST_TIME, sender: nil)
    }

    

    
    func completeSignIn(id: String, userData: Dictionary<String,AnyObject>) {
        DataService.ds.createFirebaseDBUser(id, userData: userData)
        let keychainResults = KeychainWrapper.setString(id, forKey: KEY_UID)
        print("LOONG: Data saved to keychain \(keychainResults)")

    }

    
    
    @IBAction func attemptLogin(sender: UIButton!) {
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("LOONG: Email user authenticated with Firebase")
                    if let user = user {
                        
                        let userData: Dictionary<String,AnyObject> = [
                        "provider": user.providerID,
                        "displayName": user.displayName! ,
                        "displayPicIdentifier": user.photoURL!.absoluteString
                        ]
                        
                    self.completeSignIn(user.uid, userData: userData)
                    self.enterMain()
                    }
                } else {
                    FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("LOONG: Unable to authenticate with Firebase using email")
                            self.showErrorAlert("Could not create account", msg: "Problem creating account. Try something else")

                        } else {
                            print("LOONG: Successfully created and authenticated with Firebase")
                            if let user = user {
                                let changeRequest = user.profileChangeRequest()
                                changeRequest.displayName = "blank"
                                changeRequest.photoURL = NSURL(string:"blank")
                                changeRequest.commitChangesWithCompletion({ (error) in
                                    if let error = error {
                                        print("error1")
                                    } else {
                                        print("profile updated")
                                        let userData: Dictionary<String,AnyObject> = [
                                            "provider": user.providerID,
                                            "displayName": user.displayName!,
                                            "displayPicIdentifier": user.photoURL!.absoluteString
                                        ]
                                        print("profile saved")
                                        self.completeSignIn(user.uid, userData: userData)
                                        //                          self.enterMain()
                                        self.newUser()
                                    }
                                })

                            }
                        }
                    })
                }
            })
        } else {
            self.showErrorAlert("Could not login", msg: "Please check your username or password")
            
        }
        
    }

}

