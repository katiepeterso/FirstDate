//
//  MessagingViewController.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-10.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit
import Parse
import JSQMessagesViewController

class MessagingViewController: JSQMessagesViewController {

    var messages = [Message]()
    var receiver: User?
    var idea: DateIdea?
    
    let bubbleFactory = JSQMessagesBubbleImageFactory()
    var senderPhoto: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = User.currentUser() else {
            return
        }
        
        self.senderDisplayName = currentUser.username
        senderId = currentUser.objectId
        
        self.collectionView!.dataSource = self
        self.collectionView!.delegate = self
        fetchConversation()
        
        self.inputToolbar!.contentView!.leftBarButtonItem = nil
        self.navigationController!.navigationBarHidden = false
    }
    
    func fetchConversation() {
        guard let currentUser = User.currentUser(),
            let receiver = receiver, let dateIdea = idea, let messagesArray = dateIdea.messages as? [Message]
            else {
                return
        }
        
        for message in messagesArray {
            if (message.sendingUser == currentUser && message.receivingUser == receiver) || (message.sendingUser == receiver && message.receivingUser == currentUser) {
                self.messages.append(message)
            }
        }
        self.collectionView?.reloadData()
    }
    
    //MARK: - JSQMessagesCollectionViewDataSource -
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        if self.messages[indexPath.item].receivingUser == User.currentUser() {
            self.messages[indexPath.item].isRead = NSNumber(bool: true)
            self.messages[indexPath.item].saveInBackground()
        }
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.item)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        if(messages[indexPath.item].sendingUser == User.currentUser()) {
            return bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor (red: 80.0/255.0, green: 210.0/255.0, blue: 194.0/255.0, alpha: 1.0))
        } else {
            return bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor (red: 255.0/255.0, green: 46.0/255.0, blue: 99.0/255.0, alpha: 1.0))
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
//        let message = messages[indexPath.item]
//        if (self.senderPhoto == nil || (User.currentUser() != message.receivingUser)) {
//            PhotoHelper.getPhotoInBackground(message.sendingUser.userPhoto) { (resultImage) -> Void in
//                self.senderPhoto = resultImage!
//                self.collectionView!.reloadData()
//            }
//            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
//        } else {
//            return JSQMessagesAvatarImageFactory.avatarImageWithImage(self.senderPhoto, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
//        }
//                    PhotoHelper.getPhotoInBackground(message.sendingUser.userPhoto) { (resultImage) -> Void in
//                        self.senderPhoto = resultImage!
//                        self.collectionView!.reloadData()
//                    }
//        
//        return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        return nil
    }
    
    //MARK: - Send Message -
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let newMessage = Message(text: text, sender: User.currentUser()!, receiver: receiver!)
        self.messages.append(newMessage)
        idea!.messages = self.messages
        do {
            try idea!.save()
        }
        catch {
            print("Failed to save idea")
        }
        
        newMessage.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                PushNotificationHelper.pushNotificationTo(self.receiver!, withMessage: "\(senderDisplayName) has sent you a message")
            } else {
                let alertController = UIAlertController(title: "An error occurred!", message: "Please try sending your message again", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
//        do {
//            try newMessage.save()
//            PushNotificationHelper.pushNotificationTo(receiver!, withMessage: "\(senderDisplayName) has sent you a message")
//        }
//        catch {
//            let alertController = UIAlertController(title: "An error occurred!", message: "Please try sending your message again", preferredStyle: .Alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//            self.presentViewController(alertController, animated: true, completion: nil)
//        }
        finishSendingMessageAnimated(true)
    }

    //MARK: - UICollectionView DataSource -
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        cell.avatarImageView!.contentMode = .ScaleAspectFill
        
        return cell
    }
}