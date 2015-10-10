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
    var receiver = User()
    
    let bubbleFactory = JSQMessagesBubbleImageFactory()
    var senderPhoto = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (User.currentUser() != nil) {
            self.senderDisplayName = User.currentUser()!.username
            senderId = User.currentUser()!.objectId
        }
        
        self.collectionView!.dataSource = self
        self.collectionView!.delegate = self
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
    
    
    //MARK: - JSQMessagesCollectionViewDataSource -
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
    
    //MARK: - Send Message -
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let newMessage = Message(text: text, sender: User.currentUser()!, receiver: User.currentUser()!)
        self.messages.append(newMessage)
        newMessage.saveInBackground()
        
        finishSendingMessageAnimated(true)
    }


//    override func finishSendingMessageAnimated(animated: Bool) {
//        var textView = self.inputToolbar?.contentView?.textView
//        textView?.text = nil
//    
//    UITextView *textView = self.inputToolbar.contentView.textView;
//    textView.text = nil;
//    [textView.undoManager removeAllActions];
//    
//    [self.inputToolbar toggleSendButtonEnabled];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:textView];
//    
//    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
//    [self.collectionView reloadData];
//    
//    if (self.automaticallyScrollsToMostRecentMessage) {
//    [self scrollToBottomAnimated:animated];
//    }
//    }


    //MARK: - UICollectionView DataSource -
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        cell.avatarImageView!.contentMode = .ScaleAspectFill
        
        return cell
        
        
    }

    
    /**
    *  The collection view cell identifier to use for dequeuing outgoing message collection view cells
    *  in the collectionView for text messages.
    *
    *  @discussion This cell identifier is used for outgoing text message data items.
    *  The default value is the string returned by `[JSQMessagesCollectionViewCellOutgoing cellReuseIdentifier]`.
    *  This value must not be `nil`.
    *
    *  @see JSQMessagesCollectionViewCellOutgoing.
    *
    *  @warning Overriding this property's default value is *not* recommended.
    *  You should only override this property's default value if you are proividing your own cell prototypes.
    *  These prototypes must be registered with the collectionView for reuse and you are then responsible for
    *  completely overriding many delegate and data source methods for the collectionView,
    *  including `collectionView:cellForItemAtIndexPath:`.
    */
//    public var outgoingCellIdentifier: String!
    
    /**
    *  The collection view cell identifier to use for dequeuing outgoing message collection view cells
    *  in the collectionView for media messages.
    *
    *  @discussion This cell identifier is used for outgoing media message data items.
    *  The default value is the string returned by `[JSQMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier]`.
    *  This value must not be `nil`.
    *
    *  @see JSQMessagesCollectionViewCellOutgoing.
    *
    *  @warning Overriding this property's default value is *not* recommended.
    *  You should only override this property's default value if you are proividing your own cell prototypes.
    *  These prototypes must be registered with the collectionView for reuse and you are then responsible for
    *  completely overriding many delegate and data source methods for the collectionView,
    *  including `collectionView:cellForItemAtIndexPath:`.
    */
//    public var outgoingMediaCellIdentifier: String!
    
    /**
    *  The collection view cell identifier to use for dequeuing incoming message collection view cells
    *  in the collectionView for text messages.
    *
    *  @discussion This cell identifier is used for incoming text message data items.
    *  The default value is the string returned by `[JSQMessagesCollectionViewCellIncoming cellReuseIdentifier]`.
    *  This value must not be `nil`.
    *
    *  @see JSQMessagesCollectionViewCellIncoming.
    *
    *  @warning Overriding this property's default value is *not* recommended.
    *  You should only override this property's default value if you are proividing your own cell prototypes.
    *  These prototypes must be registered with the collectionView for reuse and you are then responsible for
    *  completely overriding many delegate and data source methods for the collectionView,
    *  including `collectionView:cellForItemAtIndexPath:`.
    */
//    public var incomingCellIdentifier: String!
    
    
    /**
    *  Specifies whether or not the view controller should show the typing indicator for an incoming message.
    *
    *  @discussion Setting this property to `YES` will animate showing the typing indicator immediately.
    *  Setting this property to `NO` will animate hiding the typing indicator immediately. You will need to scroll
    *  to the bottom of the collection view in order to see the typing indicator. You may use `scrollToBottomAnimated:` for this.
    */
//    public var showTypingIndicator: Bool
    
    /**
    *  Specifies whether or not the view controller should show the "load earlier messages" header view.
    *
    *  @discussion Setting this property to `YES` will show the header view immediately.
    *  Settings this property to `NO` will hide the header view immediately. You will need to scroll to
    *  the top of the collection view in order to see the header.
    */
//    public var showLoadEarlierMessagesHeader: Bool
    
    /**
    *  Specifies an additional inset amount to be added to the collectionView's contentInsets.top value.
    *
    *  @discussion Use this property to adjust the top content inset to account for a custom subview at the top of your view controller.
    */
//    public var topContentAdditionalInset: CGFloat
    
    
    /**
    *  This method is called when the user taps the accessory button on the `inputToolbar`.
    *
    *  @param sender The accessory button that was pressed by the user.
    */
//    public func didPressAccessoryButton(sender: UIButton!)
    
    /**
    *  Animates the sending of a new message. See `finishSendingMessageAnimated:` for more details.
    *
    *  @see `finishSendingMessageAnimated:`.
    */
//    public func finishSendingMessage()
    
    /**
    *  Completes the "sending" of a new message by resetting the `inputToolbar`, adding a new collection view cell in the collection view,
    *  reloading the collection view, and scrolling to the newly sent message as specified by `automaticallyScrollsToMostRecentMessage`.
    *  Scrolling to the new message can be animated as specified by the animated parameter.
    *
    *  @param animated Specifies whether the sending of a message should be animated or not. Pass `YES` to animate changes, `NO` otherwise.
    *
    *  @discussion You should call this method at the end of `didPressSendButton: withMessageText: senderId: senderDisplayName: date`
    *  after adding the new message to your data source and performing any related tasks.
    *
    *  @see `automaticallyScrollsToMostRecentMessage`.
    */
//    public func finishSendingMessageAnimated(animated: Bool)
    
    /**
    *  Animates the receiving of a new message. See `finishReceivingMessageAnimated:` for more details.
    *
    *  @see `finishReceivingMessageAnimated:`.
    */
//    public func finishReceivingMessage()
    
    /**
    *  Completes the "receiving" of a new message by showing the typing indicator, adding a new collection view cell in the collection view,
    *  reloading the collection view, and scrolling to the newly sent message as specified by `automaticallyScrollsToMostRecentMessage`.
    *  Scrolling to the new message can be animated as specified by the animated parameter.
    *
    *  @param animated Specifies whether the receiving of a message should be animated or not. Pass `YES` to animate changes, `NO` otherwise.
    *
    *  @discussion You should call this method after adding a new "received" message to your data source and performing any related tasks.
    *
    *  @see `automaticallyScrollsToMostRecentMessage`.
    */
//    public func finishReceivingMessageAnimated(animated: Bool)
    
    /**
    *  Scrolls the collection view such that the bottom most cell is completely visible, above the `inputToolbar`.
    *
    *  @param animated Pass `YES` if you want to animate scrolling, `NO` if it should be immediate.
    */
//    public func scrollToBottomAnimated(animated: Bool)
}