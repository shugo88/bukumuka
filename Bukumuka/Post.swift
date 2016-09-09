//
//  Post.swift
//  Bukumuka
//
//  Created by Nicole on 06/09/2016.
//  Copyright © 2016 Loong. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    private var _profilePicUrl: String!
    private var _userPost: String!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String! {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var profilePicUrl: String {
        return _profilePicUrl
    }
    
    var userPost: String {
        return _userPost
    }
    
    init(caption: String, imageUrl: String, profilePicUrl: String, likes: Int, userPost: String){
        self._caption = caption
        self._imageUrl = imageUrl
        self._profilePicUrl = profilePicUrl
        self._likes = likes
        self._userPost = userPost
    }

    init(postKey: String, postData: Dictionary<String,AnyObject>) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String{
            self._imageUrl = imageUrl
        }
        
        if let profilePicUrl = postData["profilePicUrl"] as? String {
            self._profilePicUrl = profilePicUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let userPost = postData["userPost"] as? String {
            self._userPost = userPost
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)

    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
            
        } else {
            
            _likes = _likes - 1
            
        }
     _postRef.child("likes").setValue(_likes)
    }
    
}