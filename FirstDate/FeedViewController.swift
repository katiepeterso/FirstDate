//
//  FeedViewController.swift
//  FirstDate
//
//  Created by Alp Eren Can on 03/10/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController {
    
    var ideas: [DateIdea] = [DateIdea]()
    
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
        view.insertSubview(activityIndicator, belowSubview: visualEffectView)
        activityIndicator.startAnimating()
        
        animator = UIDynamicAnimator(referenceView: view)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchDateIdeas()
        
        dateView = getDateView()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.snapBehavior = UISnapBehavior(item: self.dateView!, snapToPoint: self.view.center)
        self.animator.addBehavior(self.snapBehavior)
        
    }
    
    func fetchDateIdeas() {
        let query = PFQuery(className: "DateIdea")
        query.limit = 10;
        query.findObjectsInBackgroundWithBlock { (dateIdeas, error) -> Void in
            if (error != nil) {
                self.ideas += dateIdeas as! [DateIdea]
//                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func getDateView() -> DateView {
        let dv = NSBundle.mainBundle().loadNibNamed("DateView", owner:self, options: nil)[0] as! DateView
        if self.ideas.count > 0 {
            dv.idea = self.ideas.removeFirst()
        }
        
        view.insertSubview(dv, aboveSubview: visualEffectView)
        
        dv.translatesAutoresizingMaskIntoConstraints = false
        
        let dateViewCenterX = NSLayoutConstraint(item: dv,attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
        
        let dateViewCenterY = NSLayoutConstraint(item: dv, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: -1.0, constant: 0.0)
        
        let dateViewHeight = NSLayoutConstraint(item: dv, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: dv, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0)
        
        let dateViewLeadingMargin = NSLayoutConstraint(item: dv, attribute: NSLayoutAttribute.LeadingMargin, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1.0, constant: 0.0)
        
        let dateViewTrailingMargin = NSLayoutConstraint(item: dv, attribute: NSLayoutAttribute.TrailingMargin, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.TrailingMargin, multiplier: 1.0, constant: 0.0)
        
        view.addConstraints([dateViewCenterX, dateViewCenterY, dateViewHeight, dateViewLeadingMargin, dateViewTrailingMargin])
        
        doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTapGesture:")
        dv.addGestureRecognizer(doubleTapRecognizer)
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        dv.addGestureRecognizer(panRecognizer)
        
        return dv
    }
    
    func handleDoubleTapGesture(sender: UITapGestureRecognizer) {
        
    }

    func handlePanGesture(sender: UIPanGestureRecognizer) {
        
        let location = sender.locationInView(view)

        if sender.state == UIGestureRecognizerState.Began {
            
            if snapBehavior != nil {
                animator.removeBehavior(snapBehavior)
            }
            
            // create a new incoming dateView
            incomingDateView = getDateView()

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
                        self.fetchDateIdeas()
                    }
                })
            }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
