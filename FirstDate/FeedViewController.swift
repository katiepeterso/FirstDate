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
    var heartCount: Int32 = 0
    var hearts: [DateIdea] = [DateIdea]()
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    var dateView: DateView!
    var incomingDateView: DateView!
    
    var doubleTapRecognizer: UITapGestureRecognizer!
    var panRecognizer: UIPanGestureRecognizer!
    
    var activityIndicator: UIActivityIndicatorView!
    
    var animator:UIDynamicAnimator!
    var snapBehavior: UISnapBehavior!
    var attachmentBehavior: (UIAttachmentBehavior!, UIAttachmentBehavior!)
    var gravityBehavior: UIGravityBehavior!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.center = view.center
        activityIndicator.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        view.insertSubview(activityIndicator, belowSubview: visualEffectView)
        
        activityIndicator.startAnimating()
        
        animator = UIDynamicAnimator(referenceView: view)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if User.currentUser() != nil {
            getUserHearts()
        }
        
        navigationController?.navigationBarHidden = true
        navigationItem.title = "Feed"
        
        if self.ideas.count == 0 {
            fetchDateIdeas() {
                
                if self.dateView == nil {
                    self.dateView = self.getDateView()
                    self.dateView.delegate = self
                    self.snapBehavior = UISnapBehavior(item: self.dateView, snapToPoint: self.view.center)
                    self.animator.addBehavior(self.snapBehavior)
                    for constraint in self.view.constraints {
                        if let identifier = constraint.identifier {
                            if identifier == "dateViewCenterY" {
                                constraint.constant = 0.0
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchDateIdeas(completion: (Void -> Void)?) {
        let query = PFQuery(className: "DateIdea")
        query.includeKey("user")
        query.includeKey("hearts")
        query.limit = 10;
        query.findObjectsInBackgroundWithBlock { (dateIdeas, error) -> Void in
            if (error == nil) {
                self.ideas += dateIdeas as! [DateIdea]
                self.activityIndicator.stopAnimating()
                completion?()
            }
        }
    }
    
    func getUserHearts()
    {
        let relation = User.currentUser()?.relationForKey("hearts")
        let query = relation?.query()
        query?.includeKey("user")
        query?.findObjectsInBackgroundWithBlock { (dateIdeas, error) -> Void in
            if (error == nil) {
                self.hearts = dateIdeas as! [DateIdea]
                print(self.hearts)
            }
        }
    }
    
    func getDateView() -> DateView {
        let dv = NSBundle.mainBundle().loadNibNamed("DateView", owner:self, options: nil)[0] as! DateView
        
        let idea = self.ideas.removeFirst()
        let relation = idea.relationForKey("heartedBy")
        let query = relation.query()
        query?.countObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if error == nil {
                self.heartCount = result
            }
        })
        
        dv.idea = idea
        
        if hearts.contains(idea) {
            dv.hearted = true
        }
        
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
    
    func handleDoubleTapGesture(sender: UITapGestureRecognizer) {
        
//        dateView.hearted(dateView.heartButton)
        animator.removeAllBehaviors()
        
        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: { () -> Void in
            self.dateView.frame = self.view.frame
            self.dateView.layer.cornerRadius = 0
            self.dateView.dateImageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height / 2)
            self.dateView.headerView.alpha = 0
            self.dateView.footerView.alpha = 0
            }, completion: { finished in
                self.performSegueWithIdentifier("showDetail", sender: self)
        })
    }

    func handlePanGesture(sender: UIPanGestureRecognizer) {
        
        let location = sender.locationInView(view)

        if sender.state == UIGestureRecognizerState.Began {
            
            if snapBehavior != nil {
                animator.removeBehavior(snapBehavior)
            }
            
            // create a new incoming dateView
            incomingDateView = getDateView()
            incomingDateView.delegate = self

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
                
                
                delay(0.3, closure: { () -> () in
                    self.dateView.removeFromSuperview()
                    self.dateView = self.incomingDateView
                    
                    if self.ideas.count < 5 {
                        self.fetchDateIdeas(nil)
                    }
                })
            } else if translation.y < -50 {
                
                animator.removeAllBehaviors()
                
                dateView.frame = CGRectMake(16, dateView.frame.origin.y + translation.y , dateView.frame.width, dateView.frame.height)
                
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
            } else {
                let userProfileVC = segue.destinationViewController as! UserProfileViewController
                userProfileVC.heartedDateIdeas = self.hearts
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
    
    // MARK: Date View Delegate
    
    func dateViewShouldHeart(dateView: DateView) -> Bool {
        if (User.currentUser() != nil) {
            return true
        } else {
//            performSegueWithIdentifier("showLogin", sender: <#T##AnyObject?#>)
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
    }
    
    // MARK: Login View Controller Delegate
    
    func loginViewController(loginViewController: LoginViewController!, didLoginUser user: User!) {
        if user != nil {
            getUserHearts()
        }
    }

}
