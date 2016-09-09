//
//  PostCell.swift
//  Bukumuka
//
//  Created by Nicole on 05/09/2016.
//  Copyright © 2016 Loong. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var likeImg: UIImageView!

    var post: Post!
    var likesref: FIRDatabaseReference!
    let user = FIRAuth.auth()?.currentUser
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
    
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        postImg.clipsToBounds = true

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(post: Post, img: UIImage? = nil, displayPic: UIImage? = nil) {
        self.post = post
        likesref = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        self.usernameLbl.text = post.userPost
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        if displayPic != nil {
            self.profileImg.image = displayPic
        } else {
            let displayPicRef = FIRStorage.storage().referenceForURL(post.profilePicUrl)
            displayPicRef.dataWithMaxSize(2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("LOONG: Unable to download Display Pic from Firebase storage")
                } else {
                    print("LOONG: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let displayPic = UIImage(data: imgData) {
                            self.profileImg.image = displayPic
                            FeedVC.imageCache.setObject(displayPic, forKey: post.profilePicUrl)
                        }
                    }
                }
            })
            
        }
        
        if img != nil {
            self.postImg.image = img
        } else {
            let ref = FIRStorage.storage().referenceForURL(post.imageUrl!)
            ref.dataWithMaxSize(2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("LOONG: Unable to download image from Firebase storage")
                } else {
                    print("LOONG: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl)
                        }
                    }
                }
            })
        
        }
        
        likesref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in

            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named:"heart-empty")
            } else {
                self.likeImg.image = UIImage(named: "heart-full")
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                self.likesref.setValue(true)
                self.likeImg.image = UIImage(named:"heart-full")
                self.post.adjustLikes(true)
            } else {
                self.likeImg.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likesref.removeValue()
            }
        })
    }
}
