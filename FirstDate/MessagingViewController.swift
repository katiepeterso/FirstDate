//
//  MessagingViewController.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-08.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit
import Parse
import JSQMessagesViewController

class MessagingViewController: JSQMessagesViewController {
    
    var messages = [Message]()
    
    let bubbleFactory = JSQMessagesBubbleImageFactory()
    var senderPhoto = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        if (User.currentUser() != nil) {
            self.senderDisplayName = User.currentUser()!.username
            senderId = User.currentUser()!.objectId
        }
        
        fetchConversation()
    }
    
    func fetchConversation() {
        let getMessages = PFQuery(className:"Message")
        getMessages.whereKey("sender", equalTo:User.currentUser()!)
        getMessages.includeKey("sender")
        getMessages.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if(results!.count != 0) {
                self.messages += results as! [Message]
            }
        }
    }
        
        
    //MARK: JSQMessagesCollectionViewDataSource
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.item)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        if(messages[indexPath.item].sendingUser == User.currentUser()) {
            return bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor (red: 80.0/255.0, green: 210.0/255.0, blue: 194.0/255.0, alpha: 1.0))
        } else {
            return bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor (red: 158.0/255.0, green: 37.0/255.0, blue: 143.0/255.0, alpha: 1.0))
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        PhotoHelper.getPhotoInBackground(self.messages[indexPath.item].sendingUser.userPhoto) { (resultImage) -> Void in
            self.senderPhoto = resultImage!
        }
        return JSQMessagesAvatarImageFactory.avatarImageWithImage(self.senderPhoto, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
    }
}
