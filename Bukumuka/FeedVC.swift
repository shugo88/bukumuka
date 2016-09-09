//
//  FeedVC.swift
//  Bukumuka
//
//  Created by Nicole on 05/09/2016.
//  Copyright © 2016 Loong. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet  weak var tableView: UITableView!
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var postField: MaterialTextField!
    
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache = NSCache().self
    var imageSelected = false
    let user = FIRAuth.auth()?.currentUser

    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 358
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        //firebase listener
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                self.posts = []
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return posts.count
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info [UIImagePickerControllerEditedImage] as? UIImage{
        addImage.image = image
        imageSelected = true
        } else {
            print("LOONG: A valid image wasn't selected")
        }
        imagePicker.dismissViewControllerAnimated(true) {
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            if let img = FeedVC.imageCache.objectForKey(post.imageUrl) {
                if let displayPic = FeedVC.imageCache.objectForKey(post.profilePicUrl) {
                    cell.configureCell(post, img: img as? UIImage, displayPic: displayPic as? UIImage)
            
            }
            } else {
                cell.configureCell(post)
            }
            return cell

        } else {
        return PostCell()
        }
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let post = posts[indexPath.row]
//        
//        if post.imageUrl == nil {
//            return 150
//        } else {
//            return tableView.estimatedRowHeight
//        }
//    }
   
    @IBAction func signOutBtnTapped(sender: AnyObject) {
        let keychainResult = KeychainWrapper.removeObjectForKey(KEY_UID)
        print("LOONG: ID removed from Keychain \(keychainResult)")

        try! FIRAuth.auth()?.signOut()
        dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    @IBAction func selectImg(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        //opposite of 'if let'
        guard let caption = postField.text where caption != "" else {
            print("LOONG: Caption must be entered")
            return
        }
        //image should be addimage to your image.. if nothing then print...
        guard let img = addImage.image where imageSelected == true else {
            print("LOONG: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().UUIDString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).putData(imgData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print("LOONG: Unable to upload image to Firebase Storage")
                } else {
                    print("LOONG: Successfully uploaded image to Firebase Storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                    self.postToFirebase(url, profilePicUrl: (self.user?.photoURL?.absoluteString)!)
                    }
                }
            })
            }
        }
    
    func postToFirebase(imgUrl: String, profilePicUrl: String) {
        let post: Dictionary<String, AnyObject> = [
            "caption": postField.text!,
            "imageUrl": imgUrl,
            "profilePicUrl": profilePicUrl,
            "likes": 0,
            "userPost" : (user?.displayName)!
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        postField.text = ""
        imageSelected = false
        addImage.image = UIImage(named: "camera")
        print("LOONG: Successfully added post")
        tableView.reloadData()
    }
    
    }
    
    



