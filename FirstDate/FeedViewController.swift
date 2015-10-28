//
//  FeedViewController.swift
//  FirstDate
//
//  Created by Alp Eren Can on 03/10/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController, DateViewDelegate, LoginViewControllerDelegate {
    
    var ideas: [DateIdea] = [DateIdea]()
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    var dateView: DateView!
    var incomingDateView: DateView?
    
    var doubleTapRecognizer: UITapGestureRecognizer!
    var panRecognizer: UIPanGestureRecognizer!
    
    var activityIndicator: UIActivityIndicatorView!
    
    var animator:UIDynamicAnimator!
    var snapBehavior: UISnapBehavior!
    var attachmentBehavior: UIAttachmentBehavior!
    var gravityBehavior: UIGravityBehavior!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray) // TODO: Change to custom activity indicator
        activityIndicator.center = view.center
        activityIndicator.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        view.insertSubview(activityIndicator, aboveSubview: visualEffectView)
        
        animator = UIDynamicAnimator(referenceView: view)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBarHidden = true
        navigationItem.title = "Explore"
        
        if dateView == nil {
            activityIndicator.startAnimating()
        }
        
        
        let querySavedDateIdea = DateIdea.query()!
        querySavedDateIdea.fromPinWithName("LastDateIdeaViewed")
        querySavedDateIdea.includeKey("user")
        querySavedDateIdea.findObjectsInBackgroundWithBlock { (dateIdeas, error) -> Void in
            if let dateIdeas = dateIdeas as? [DateIdea],
                let firstIdea = dateIdeas.first {
                    
                    if self.dateView == nil  {
                        self.dateView = self.createDateViewWithIdea(firstIdea)
                        self.showDateView(self.dateView)
                    }
            }
        }
        
        fetchDateIdeas() {
            if self.dateView == nil {
                self.dateView = self.createDateViewWithIdea(self.ideas.removeFirst())
                self.showDateView(self.dateView)
            }
        }
    }
    
    // MARK: - Appearance
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return AppearanceHelper.statusBarColor(backgroundImageView?.image)
    }
    
    // MARK: - Fetch New Data
    
    func fetchDateIdeas(completion:(() -> ())?) {
        if self.ideas.count >= 5 {
            return
        }
        
        let lastIdea = self.ideas.last
        var queryDate: NSDate

        let c = NSDateComponents()
        c.year = 2015
        c.month = 1
        c.day = 1
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let earliestDate = calendar!.dateFromComponents(c)
        
        if User.currentUser() == nil{
            if lastIdea == nil {
                queryDate = earliestDate!
            } else {
                queryDate = (lastIdea?.createdAt)!
            }
        } else {
            if lastIdea == nil {
                if User.currentUser()?.lastSeenDateIdeaCreatedAt != nil  {
                    queryDate = (User.currentUser()?.lastSeenDateIdeaCreatedAt)!
                } else {
                    queryDate = earliestDate!
                }
            } else {
                queryDate = lastIdea!.createdAt!
            }
        }
        
        let query = DateIdea.query()
        query?.addAscendingOrder("createdAt")
        query?.includeKey("user")
        query?.limit = 10;
        if let user = User.currentUser() {
            query?.whereKey("user", notEqualTo: user)
        }
        query?.whereKey("createdAt", greaterThan: queryDate)
        query?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if (error == nil) {
                if let dateIdeas = objects as? [DateIdea] where dateIdeas.count > 0 {
                    self.ideas += dateIdeas
                    
                    for idea in self.ideas {
                        if let photo = idea.photo {
                            PhotoHelper.getPhotoInBackground(photo, completionHandler: { (resultImage) -> Void in
                                // download to cache
                            })
                        }
                        
                        if let user = idea.user,
                            let photo = user.userPhoto {
                                PhotoHelper.getPhotoInBackground(photo, completionHandler: { (resultImage) -> Void in
                                    // download to cache
                                })
                                
                        }
                    }
                    
                    completion?()
                }
            }
        }
    }
    
    // MARK: - Update Parse
    func updateLastSeenDateIdeaDate() {
        if let user = User.currentUser() {
            let lastSeenDate = NSDate(timeInterval: 1.0, sinceDate: (dateView.idea?.createdAt)!)
            user.lastSeenDateIdeaCreatedAt = lastSeenDate
            user.saveInBackground()
        }
    }
    
    // MARK: - Create Date View
    
    func createDateViewWithIdea(idea: DateIdea) -> DateView {
        let dv = NSBundle.mainBundle().loadNibNamed("DateView", owner:self, options: nil)[0] as! DateView
        
        let dateViewDimension = view.frame.width - (view.layoutMargins.left + view.layoutMargins.right)
        dv.frame = CGRectMake(0, 0, dateViewDimension, dateViewDimension)
        
        dv.idea = idea
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { () -> Void in
            var dateImage: UIImage?
            var userImage: UIImage?
            var heartCount: Int!
            
            if let photo = idea.photo,
                let dateImageData = try? photo.getData() {
                dateImage = UIImage(data: dateImageData)
            }
            
            if let user = idea.user,
                let photo = user.userPhoto,
                userImageData = try? photo.getData() {
                    userImage = UIImage(data: userImageData)
            }
            
            var heartCountError: NSError? = nil
            if let heartCountQuery = idea.heartedBy.query() {
                heartCount = heartCountQuery.countObjects(&heartCountError)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // first run code:
                if self.dateView == dv {
                    self.backgroundImageView.image = dateImage
                    self.setNeedsStatusBarAppearanceUpdate()
                }
                dv.dateImageView.image = dateImage
                dv.userImageView.image = userImage
                if heartCountError == nil {
                    dv.heartCount = heartCount
                } else {
                    print("An error occurred: \(heartCountError)")
                }
                self.activityIndicator.stopAnimating()
            })
        }
        
        view.insertSubview(dv, aboveSubview: visualEffectView)
        
        doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTapGesture:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        dv.addGestureRecognizer(doubleTapRecognizer)
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        dv.addGestureRecognizer(panRecognizer)
        
        dv.delegate = self
        
        dv.alpha = 0.0

        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0, -view.frame.height/8)
        dv.transform = CGAffineTransformConcat(scale, translate)
        dv.center.x = view.center.x
        
        return dv
    }
    
    // MARK: - Show / Hide Views
    
    func showDateView(dv: DateView) {
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: { () -> Void in
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            dv.transform = CGAffineTransformConcat(scale, translate)
            dv.alpha = 1.0
            dv.center = self.view.center
            }, completion: { completed in
                UIView.transitionWithView(self.backgroundImageView, duration: 0.5, options: [.TransitionCrossDissolve], animations: {
                    self.backgroundImageView.image = dv.dateImageView.image
                    }, completion: {completed in
                        self.setNeedsStatusBarAppearanceUpdate()
                })
                DateIdea.unpinAllObjectsInBackgroundWithName("LastDateIdeaViewed")
                dv.idea?.pinInBackgroundWithName("LastDateIdeaViewed")
                self.updateLastSeenDateIdeaDate()
                self.activityIndicator.stopAnimating()
            })
        
    }
    
    func hideDateView(dv: DateView) {
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: { () -> Void in
            let scale = CGAffineTransformMakeScale(0.5, 0.5)
            let translate = CGAffineTransformMakeTranslation(0, -self.view.frame.height/8)
            dv.transform = CGAffineTransformConcat(scale, translate)
            dv.alpha = 0.0
            }, completion: nil)
        
    }
    
    // MARK: - Gesture Recognizers
    
    func handleDoubleTapGesture(sender: UITapGestureRecognizer) {
        dateView.heart(dateView.heartButton)
    }
    
    func handlePanGesture(sender: UIPanGestureRecognizer) {
        
        let location = sender.locationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            
            if snapBehavior != nil {
                animator.removeBehavior(snapBehavior)
            }
            
            // create a new incoming dateView
            if (incomingDateView == nil) && (ideas.count > 0) {
                incomingDateView = createDateViewWithIdea(ideas.removeFirst())
            }
            // animate them together
            
            let currentDateViewLocation = sender.locationInView(dateView)
            
            let centerOffset = UIOffsetMake(currentDateViewLocation.x - CGRectGetMidX(dateView.bounds), currentDateViewLocation.y - CGRectGetMidY(dateView.bounds))
            
            attachmentBehavior = UIAttachmentBehavior(item: dateView, offsetFromCenter: centerOffset, attachedToAnchor: location)
            attachmentBehavior.frequency = 0
            
            animator.addBehavior(attachmentBehavior)
        } else if sender.state == UIGestureRecognizerState.Changed {
            attachmentBehavior.anchorPoint = location
            let translation = sender.translationInView(view)
            
            let alpha = max(min(translation.y / 200, 1), 0)
            
            if let incoming = incomingDateView {
                incoming.alpha = alpha
            }
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            
            animator.removeAllBehaviors()
            
            let translation = sender.translationInView(view)
            
            if translation.y > 100 /*|| fabs(translation.x) > 100*/ {
                
                let outgoing = self.dateView
                
                let gravity = UIGravityBehavior(items: [dateView])
                gravity.gravityDirection = CGVectorMake(0, 10)
                animator.addBehavior(gravity)
                
                if let incoming = incomingDateView {
                    showDateView(incoming)
                } else {
                    DateIdea.unpinAllObjectsInBackgroundWithName("LastDateIdeaViewed")
                }
                
                gravity.action = { [weak gravity] in
                    
                    if !self.view.frame.intersects(outgoing.frame) {
                        if let g = gravity {
                            self.animator.removeBehavior(g)
                        }
                        
                        outgoing.removeFromSuperview()
                        self.fetchDateIdeas(nil)
                    }
                    
                }
                
                self.dateView = self.incomingDateView
                self.incomingDateView = nil
                
            } else if translation.y < -75 {
                
                dateView.transform = CGAffineTransformMakeRotation(0);
                
                UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: { () -> Void in
                    self.dateView.layer.cornerRadius = 0
                    self.dateView.headerView.alpha = 0
                    self.dateView.footerView.alpha = 0
                    
                    self.dateView.frame = self.view.bounds
                    
                    self.dateView.dateImageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height/2)
                    
                    
                    }, completion: { finished in
                        self.performSegueWithIdentifier("showDetail", sender: self)
                })
            } else {
                
                snapBehavior = UISnapBehavior(item: dateView, snapToPoint: view.center)
                animator.addBehavior(snapBehavior)
                
                if let incoming = incomingDateView {
                    hideDateView(incoming)
                }
                
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func showSettings(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if User.currentUser() != nil {
            alertController.addAction(UIAlertAction(title: "Log Out", style: .Destructive, handler: { (action) -> Void in
                User.logOut()
                
                self.performSegueWithIdentifier("showLogin", sender: self)
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "Login", style: .Default, handler: { (action) -> Void in
                
                self.performSegueWithIdentifier("showLogin", sender: self)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:nil))
        alertController.view.tintColor = UIColor(red: 80.0/255.0, green: 210.0/255.0, blue: 194.0/255.0, alpha: 1.0)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAdd" {
            if User.currentUser() == nil {
                performSegueWithIdentifier("showLogin", sender: sender)
            }
            
        } else if segue.identifier == "showDetail" {
            let detailVC = segue.destinationViewController as! DetailViewController
            detailVC.idea = dateView.idea
        } else if segue.identifier == "showProfile" {
            if User.currentUser() == nil {
                performSegueWithIdentifier("showLogin", sender: sender)
            } else {
                let profileVC = segue.destinationViewController as! UserProfileViewController
                profileVC.selectedUser = User.currentUser()
            }
        } else if segue.identifier == "showLogin" {
            let navigationVC = segue.destinationViewController as! UINavigationController
            let loginVC = navigationVC.topViewController as! LoginViewController
            loginVC.delegate = self
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
        if (self.dateView != nil) {
            self.dateView.layer.cornerRadius = self.dateView.frame.height / 24.0
            self.dateView.headerView.alpha = 1.0
            self.dateView.footerView.alpha = 1.0
            
            let dateViewDimension = self.view.frame.width - (self.view.layoutMargins.left + self.view.layoutMargins.right)
            self.dateView.frame = CGRectMake(0, 0, dateViewDimension, dateViewDimension)
            self.dateView.dateImageView.frame = self.dateView.frame
            
            self.dateView.center = self.view.center
        }
        
    }
    
    // MARK: - Date View Delegate
    
    func dateViewShouldHeart(dateView: DateView) -> Bool {
        if (User.currentUser() != nil) {
            return true
        } else {
            performSegueWithIdentifier("showLogin", sender: self)
            return false
        }
    }
    
    func dateViewDidHeart(dateView: DateView) {
        let relationForUser = User.currentUser()?.relationForKey("hearts")
        relationForUser?.addObject(dateView.idea!)
        User.currentUser()?.saveInBackground()
        
        let relationForDateIdea = dateView.idea!.relationForKey("heartedBy")
        relationForDateIdea.addObject(User.currentUser()!)
        dateView.idea!.saveInBackground()
        
        animator.removeAllBehaviors()
        
        // create a new incoming dateView
        if (self.incomingDateView == nil) && (ideas.count > 0){
            
            if let idea = self.ideas.first {
                
                self.incomingDateView = self.createDateViewWithIdea(idea)
                self.ideas.removeFirst()
                
            } else {
            
                // no more ideas!!!
                print("no more ideas found!")
            }
            
        }
        
        if let incoming = incomingDateView {
            UIView.animateKeyframesWithDuration(0.5, delay: 0.2, options: [], animations: {
                
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.2, animations: {
                    incoming.alpha = 0.5
                })
                
                UIView.addKeyframeWithRelativeStartTime(0.2, relativeDuration: 0.8, animations: {
                    let scale = CGAffineTransformMakeScale(0.01, 0.01)
                    self.dateView.transform = scale
                    self.dateView.alpha = 0.0
                    
                })
                
                UIView.addKeyframeWithRelativeStartTime(0.2, relativeDuration: 0.8, animations: {
                    let scale = CGAffineTransformMakeScale(1, 1)
                    let translate = CGAffineTransformMakeTranslation(0, 0)
                    incoming.transform = CGAffineTransformConcat(scale, translate)
                    incoming.alpha = 1.0
                    incoming.center = self.view.center
                })
                }) { (completed) -> Void in
                    // animations completed
                    UIView.transitionWithView(self.backgroundImageView, duration: 0.5, options: [.TransitionCrossDissolve], animations: {
                        self.backgroundImageView.image = self.incomingDateView?.dateImageView.image
                        }, completion: nil)
                    self.dateView.removeFromSuperview()
                    self.dateView = incoming
                    self.incomingDateView = nil
                    self.fetchDateIdeas(nil)
                    self.updateLastSeenDateIdeaDate()
        }
        }
    
    }
    
    // MARK: - Login View Controller Delegate
    
    func loginViewController(loginViewController: LoginViewController!, didLoginUser user: User!) {
        if user != nil {
        }
    }
    
}
