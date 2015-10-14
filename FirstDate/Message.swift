//
//  Message.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-10.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit
import Parse
import JSQMessagesViewController
import Foundation

class Message: PFObject, PFSubclassing, JSQMessageData {
    @NSManaged var sendingUser: User
    @NSManaged var messagingHash: NSNumber
    @NSManaged var messagingText: NSString
    @NSManaged var receivingUser: User
    @NSManaged var idea: DateIdea
    @NSManaged var isRead: NSNumber
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    init(text: String, sender: User, receiver: User, idea: DateIdea) {
        super.init()
        self.messagingText = text
        self.sendingUser = sender
        let now = NSDate()
        self.messagingHash = NSNumber(integer: (self.sendingUser.objectId!.hash ^ now.hash ^ self.messagingText.hash))
        self.receivingUser = receiver
        self.idea = idea
        self.isRead = NSNumber(bool: false);
    }
    
    override init() {
        super.init()
    }
    
    static func parseClassName() -> String {
        return "Message"
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