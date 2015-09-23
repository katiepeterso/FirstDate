//
//  Comment.swift
//  FirstDate
//
//  Created by Alp Eren Can on 22/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit
import Parse

class Comment : PFObject, PFSubclassing {
    
    @NSManaged var user: User
    @NSManaged var content: String
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Comment"
    }
    
    init(user: User, content: String) {
        super.init()
        self.user = user
        self.content = content
    }
    
}