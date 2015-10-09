//
//  FeedViewController.swift
//  FirstDate
//
//  Created by Alp Eren Can on 03/10/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit
import Parse
import DBImageColorPicker

class FeedViewController: UIViewController, DateViewDelegate, LoginViewControllerDelegate {
    
    var colorPicker: DBImageColorPicker!
    
    var ideas: [DateIdea] = [DateIdea]()
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    var dateView: DateView!
    var incomingDateView: DateView!
    
    var doubleTapRecognizer: UITapGestureRecognizer!
    var panRecognizer: UIPanGestureRecognizer!
    
    var activityIndicator: UIActivityIndicatorView!
    
    var animator:UIDynamicAnimator!
    var snapBehavior: UISnapBehavior!
    var attachmentBehavior: (UIAttachmentBehavior!, UIAttachmentBehavior!)
    var gravityBehavior: UIGravityBehavior!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        backgroundImageView.image = nil
        view.backgroundColor = UIColor(red: 80.0/255, green: 210.0/255.0, blue: 194.0/255.0, alpha: 1.0)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge) // TODO: Change to custom activity indicator
        activityIndicator.center = view.center
        activityIndicator.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        view.insertSubview(activityIndicator, belowSubview: visualEffectView)
        
        activityIndicator.startAnimating()
        
        animator = UIDynamicAnimator(referenceView: view)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBarHidden = true
        navigationItem.title = "Explore"
        
        
        let querySavedDateIdea = DateIdea.query()!
        querySavedDateIdea.fromPinWithName("LastDateIdeaViewed")
        querySavedDateIdea.includeKey("user")
        querySavedDateIdea.findObjectsInBackgroundWithBlock { (dateIdeas, error) -> Void in
            if dateIdeas?.count > 0 {
                var dateIdeas = dateIdeas as! [DateIdea]
                self.activityIndicator.stopAnimating()
                
                self.dateView = self.createDateViewWithIdea(dateIdeas.removeFirst())
                self.dateView.delegate = self
                self.setupViewWithDateView(self.dateView)
                self.setupDateView(self.dateView)
                self.updateLastSeenDateIdeaDate()
            }
        }
        
        if ideas.count < 5 {
            fetchDateIdeas() { (dateIdeas, success) in
                if success {
                    self.ideas = dateIdeas
                    self.activityIndicator.stopAnimating()
                    
                    if self.dateView == nil {
                        self.dateView = self.createDateViewWithIdea(self.ideas.removeFirst())
                        self.dateView.delegate = self
                        self.setupViewWithDateView(self.dateView)
                        self.setupDateView(self.dateView)
                        self.updateLastSeenDateIdeaDate()
                    }
                } else {
                    // TODO: Handle failure
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if dateView != nil {
            DateIdea.unpinAllObjectsInBackgroundWithName("LastDateIdeaViewed")
            dateView.idea?.pinInBackgroundWithName("LastDateIdeaViewed")
        }
    }
    
    // MARK: - Fetch New Data
    
    func fetchDateIdeas(completion: ((dateIdeas: [DateIdea]!, success: Bool) -> Void)?) {
        
        let query = PFQuery(className: "DateIdea")
        query.includeKey("user")
        query.limit = 10;
//        if let user = User.currentUser() {
//            query.whereKey("createdAt", greaterThan: user.lastSeenDateIdeaCreatedAt!)
//        }
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if (error == nil) {
                let dateIdeas = objects as! [DateIdea]
                completion?(dateIdeas: dateIdeas, success: true)
            } else {
                completion?(dateIdeas: nil, success: false)
            }
        }
    }
    
    // MARK: - Setup views
    
    func setupViewWithDateView(dv: DateView) {
        backgroundImageView.image = dv.dateImageView.image
        colorPicker = DBImageColorPicker(fromImage: dv.dateImageView.image, withBackgroundType: DBImageColorPickerBackgroundType.Default)
    }
    
    func setupDateView(dv: DateView) {
        dv.dateTitleLabel.textColor = colorPicker.backgroundColor
        dv.heartCountLabel.textColor = colorPicker.backgroundColor
        snapBehavior = UISnapBehavior(item: dv, snapToPoint: view.center)
        animator.addBehavior(snapBehavior)
        for constraint in view.constraints {
            if let identifier = constraint.identifier {
                if identifier == "dateViewCenterY" {
                    constraint.constant = 0.0
                }
            }
        }
    }
    
    // MARK: - Update Parse
    func updateLastSeenDateIdeaDate() {
        if let user = User.currentUser() {
            user.lastSeenDateIdeaCreatedAt = dateView.idea?.createdAt
            user.saveEventually()
        }
    }
    
    // MARK: - Create Date View
    
    func createDateViewWithIdea(idea: DateIdea) -> DateView {
        let dv = NSBundle.mainBundle().loadNibNamed("DateView", owner:self, options: nil)[0] as! DateView
        
        dv.idea = idea
        
        PhotoHelper.getPhotoInBackground(idea.photo) { (image) in
            dv.dateImageView.image = image
        }
        
        if let user = idea.user,
            let photo = user.userPhoto {
            PhotoHelper.getPhotoInBackground(photo) { (image) in
                dv.userImageView.image = image
            }
        }
        
        let query = idea.heartedBy.query()
        query?.countObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if error == nil {
                dv.heartCount = result
            }
        })
        
        view.insertSubview(dv, aboveSubview: visualEffectView)
        
        dv.translatesAutoresizingMaskIntoConstraints = false
        
        let dateViewCenterX = NSLayoutConstraint(item: dv,attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
        
        let dateViewCenterY = NSLayoutConstraint(item: dv, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: -1000.0)
        dateViewCenterY.identifier = "dateViewCenterY"
        
        let dateViewHeight = NSLayoutConstraint(item: dv, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: dv, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0)
        
        let dateViewLeadingMargin = NSLayoutConstraint(item: dv, attribute: NSLayoutAttribute.LeadingMargin, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1.0, constant: 0.0)
        
        let dateViewTrailingMargin = NSLayoutConstraint(item: dv, attribute: NSLayoutAttribute.TrailingMargin, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.TrailingMargin, multiplier: 1.0, constant: 0.0)
        
        view.addConstraints([dateViewCenterX, dateViewCenterY, dateViewHeight, dateViewLeadingMargin, dateViewTrailingMargin])
        
        doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTapGesture:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        dv.addGestureRecognizer(doubleTapRecognizer)
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        dv.addGestureRecognizer(panRecognizer)
        
        return dv
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
                incomingDateView.delegate = self
            }

            // animate them together
            
            let currentDateViewLocation = sender.locationInView(dateView)
            let incomingDateViewLocation = sender.locationInView(incomingDateView)
            
            let centerOffset = UIOffsetMake(currentDateViewLocation.x - CGRectGetMidX(dateView.bounds), currentDateViewLocation.y - CGRectGetMidY(dateView.bounds))
            
            attachmentBehavior.0 = UIAttachmentBehavior(item: dateView, offsetFromCenter: centerOffset, attachedToAnchor: location)
            attachmentBehavior.0.frequency = 0
            
            let offScreenCenterOffset = UIOffsetMake(incomingDateViewLocation.x - CGRectGetMidX(incomingDateView.bounds), incomingDateViewLocation.y - CGRectGetMidY(incomingDateView.bounds))
            
            attachmentBehavior.1 = UIAttachmentBehavior(item: incomingDateView, offsetFromCenter: offScreenCenterOffset, attachedToAnchor: location)
            attachmentBehavior.1.frequency = 0
            
            animator.addBehavior(attachmentBehavior.0)
            animator.addBehavior(attachmentBehavior.1)
        } else if sender.state == UIGestureRecognizerState.Changed {
            attachmentBehavior.0.anchorPoint = location
            attachmentBehavior.1.anchorPoint = CGPoint(x: location.x - 100, y: location.y - 500)
        } else if sender.state == UIGestureRecognizerState.Ended {
            backgroundImageView.image = dateView.dateImageView.image
            
            animator.removeBehavior(attachmentBehavior.0)
            
            snapBehavior = UISnapBehavior(item: dateView, snapToPoint: view.center)
            animator.addBehavior(snapBehavior)
            
            animator.removeBehavior(attachmentBehavior.1)
            
            snapBehavior = UISnapBehavior(item: incomingDateView, snapToPoint: CGPoint(x: view.frame.size.width/2, y: -300))
            animator.addBehavior(snapBehavior)
            
            let translation = sender.translationInView(view)
            if translation.y > 100 {
                animator.removeAllBehaviors()
                
                let gravity = UIGravityBehavior(items: [dateView])
                gravity.gravityDirection = CGVectorMake(0, 10)
                animator.addBehavior(gravity)
                
                let snapToCenter = UISnapBehavior(item: incomingDateView, snapToPoint: view.center)
                animator.addBehavior(snapToCenter)
                
                backgroundImageView.image = incomingDateView.dateImageView.image
                
                delay(0.3, closure: { () -> () in
                    self.dateView.removeFromSuperview()
                    self.dateView = self.incomingDateView
                    self.incomingDateView = nil
                    
                    self.fetchDateIdeas(nil)
                })
            } else if translation.y < -100 {
                
                animator.removeAllBehaviors()
                
                dateView.transform = CGAffineTransformMakeRotation(0);
                
                UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: { () -> Void in
                    self.dateView.frame = self.view.bounds
                    self.dateView.layer.cornerRadius = 0
                    self.dateView.dateImageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height / 2)
                    self.dateView.headerView.alpha = 0
                    self.dateView.footerView.alpha = 0
                    }, completion: { finished in
                        self.performSegueWithIdentifier("showDetail", sender: self)
                })
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAdd" {
            if User.currentUser() == nil {
                performSegueWithIdentifier("showLogin", sender: sender)
            }
            
        } else if segue.identifier == "showDetail" {
            
        } else if segue.identifier == "showProfile" {
            if User.currentUser() == nil {
                performSegueWithIdentifier("showLogin", sender: sender)
            }
        } else if segue.identifier == "showLogin" {
            let loginVC = segue.destinationViewController as! LoginViewController
            loginVC.delegate = self
        }
    }
    
    // MARK: - Helper
    
    func delay(delay: Double, closure:() -> ()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
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
        if incomingDateView == nil {
            incomingDateView = createDateViewWithIdea(ideas.removeFirst())
            incomingDateView.delegate = self
        }
        
        UIView.animateWithDuration(2.0, animations: { () -> Void in
            self.dateView.frame = CGRectZero
            }) { (completed) -> Void in
                if completed {
                    let snapToCenter = UISnapBehavior(item: self.incomingDateView, snapToPoint: self.view.center)
                    self.animator.addBehavior(snapToCenter)
                    
                    self.dateView.removeFromSuperview()
                    self.dateView = self.incomingDateView
                    self.incomingDateView = nil
                    
                    self.fetchDateIdeas(nil)
                }
        }
    }
    
    // MARK: - Login View Controller Delegate
    
    func loginViewController(loginViewController: LoginViewController!, didLoginUser user: User!) {
        if user != nil {
        }
    }

}
