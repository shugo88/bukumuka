//
//  DataServices.swift
//  Bukumuka
//
//  Created by Nicole on 06/09/2016.
//  Copyright © 2016 Loong. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    //DB REF
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    
    
    //STORAGE REF
    private var _REF_POSTS_IMAGES = STORAGE_BASE.child("post-pics")
    private var _REF_USERPIC = STORAGE_BASE.child("user-pics")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }

    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = KeychainWrapper.stringForKey(KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    
    var REF_POST_IMAGES: FIRStorageReference {
        return _REF_POSTS_IMAGES
    }
    
    var REF_USERPIC: FIRStorageReference {
        return _REF_USERPIC
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String,AnyObject>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
    
    
}