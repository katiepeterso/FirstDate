//
//  Message.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-09.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit
import Parse
import JSQMessagesViewController
import Foundation

class Message: PFObject, JSQMessageData {
    @NSManaged var sendingUser: User
    @NSManaged var messagingHash: NSNumber
    @NSManaged var messagingText: NSString
    @NSManaged var receivingUser: User
    
    convenience init(text: String?, sender: User?, receiver: User?) {
        self.init()
        self.messagingText = text!
        self.sendingUser = sender!
        self.messagingHash = NSNumber(integer: (objectId?.hash)!)
        self.receivingUser = receiver!
        
    }
    
    func senderId() -> String! {
        return sendingUser.objectId
    }
    
    func senderDisplayName() -> String! {
        return sendingUser.username
    }
    
    func date() -> NSDate! {
        return self.createdAt
    }
    
    func isMediaMessage() -> Bool {
        return false
    }
    
    func messageHash() -> UInt {
        return messagingHash.unsignedLongValue
    }
    
    func text() -> String! {
        return messagingText as String
    }
    
}
