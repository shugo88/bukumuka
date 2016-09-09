//
//  ProfileVC.swift
//  Bukumuka
//
//  Created by Nicole on 08/09/2016.
//  Copyright © 2016 Loong. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var addCamera: UIImageView!
    @IBOutlet weak var displayName: UITextField!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
    }
    
    
    
    //After selecting image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info [UIImagePickerControllerEditedImage] as? UIImage {
            addCamera.image = image
            imageSelected = true
        } else {
            print("LOONG: A valid image wasn't selected")
        }
        imagePicker.dismissViewControllerAnimated(true) {
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String,AnyObject>) {
        DataService.ds.createFirebaseDBUser(id, userData: userData)
        let keychainResults = KeychainWrapper.setString(id, forKey: KEY_UID)
        print("LOONG: Data saved to keychain \(keychainResults)")
        
    }
    
    //Tapping the addCamera pic
    @IBAction func addImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    //Tapping the confirm button
    @IBAction func confirmBtnTapped(sender: AnyObject) {
        guard let name = displayName.text where name != "" else {
            print("LOONG: Display Name must be entered")
            return
        }
        
        guard let img = addCamera.image where imageSelected == true else {
            print("LOONG: An profile pic must be selected")
            return
            //NEED TO TAG THESE 2 INFOS to SERVER
        }
        
        //Naming and conversion of image into Firebase data
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().UUIDString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            //Storing in the Firebase storage
            DataService.ds.REF_USERPIC.child(imgUid).putData(imgData, metadata: metadata,completion: {(metadata, error) in
                if error != nil {
                    print("LOONG: Unable to store image to Firebase Storage")
                } else {
                    print("LOONG: Successfully stored display image to Firebase Storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        let user = FIRAuth.auth()?.currentUser
                        if let user = user {
                            let changeRequest = user.profileChangeRequest()
                            
                            changeRequest.displayName = self.displayName.text
                            changeRequest.photoURL = NSURL(string: url)
                            changeRequest.commitChangesWithCompletion({ (error) in
                                if let error = error {
                                    print("LOONG: Error with implementing changes")
                                } else {
                                    print("LOONG: PROFILE UPDATED")
                                    let userData: Dictionary<String,AnyObject> = [
//                                        "provider": user.providerID,
                                        "displayName": user.displayName!,
                                        "displayPicIdentifier": user.photoURL!.absoluteString
                                    ]
                                    
                                    self.completeSignIn(user.uid, userData: userData)
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                    self.performSegueWithIdentifier(SEGUE_PROFILE_SET, sender: nil)
                                }
                            })
                        }
                    }
                }
                
            
        })
        
    }
}
}
