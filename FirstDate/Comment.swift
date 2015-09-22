//
//  Comment.swift
//  FirstDate
//
//  Created by Alp Eren Can on 22/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit

class Comment : NSObject {
    
    let user: User
    let content: String
    let timeStamp: NSDate
    
    init(user: User, content: String) {
        self.user = user
        self.content = content
        self.timeStamp = NSDate()
    }
    
}