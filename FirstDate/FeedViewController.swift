//
//  FeedViewController.swift
//  FirstDate
//
//  Created by Alp Eren Can on 03/10/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {
    
    @IBOutlet weak var ideaViewCenterY: NSLayoutConstraint!
    
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    
    var ideaView: IdeaView! {
    
        didSet {
            
            view.addSubview(ideaView)
            
            ideaView.translatesAutoresizingMaskIntoConstraints = false
            
            let ideaViewCenterX = NSLayoutConstraint(item: ideaView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
            
            let ideaViewCenterY = NSLayoutConstraint(item: ideaView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: -view.frame.height)
            
            let ideaViewHeight = NSLayoutConstraint(item: ideaView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: ideaView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0)
        
            let ideaViewLeadingMargin = NSLayoutConstraint(item: ideaView, attribute: NSLayoutAttribute.LeadingMargin, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1.0, constant: 0.0)
            
            let ideaViewTrailingMargin = NSLayoutConstraint(item: ideaView, attribute: NSLayoutAttribute.TrailingMargin, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.TrailingMargin, multiplier: 1.0, constant: 0.0)
            
            view.addConstraints([ideaViewCenterX, ideaViewCenterY, ideaViewHeight, ideaViewLeadingMargin, ideaViewTrailingMargin])
            
        
        }
    }
    
    var animator:UIDynamicAnimator!
    var snapBehavior: UISnapBehavior!
    var attachmentBehavior: UIAttachmentBehavior!
    var gravityBehavior: UIGravityBehavior!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ideaView = NSBundle.mainBundle().loadNibNamed("IdeaView", owner:self, options: nil)[0] as! IdeaView
        
        animator = UIDynamicAnimator(referenceView: view)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.snapBehavior = UISnapBehavior(item: self.ideaView!, snapToPoint: self.view.center)
        self.animator.addBehavior(self.snapBehavior)

        
//        UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
//            self.ideaViewCenterY.constant = 0
//            
//            self.view.layoutIfNeeded()
//            }, completion: nil)
        
        
    }

//    @IBAction func handlePanGesture(sender: UIPanGestureRecognizer) {
//        
//        let myView = ideaView
//        let location = sender.locationInView(view)
//        let boxLocation = sender.locationInView(ideaView)
//
//        if sender.state == UIGestureRecognizerState.Began {
//            if snapBehavior != nil {
//                animator.removeBehavior(snapBehavior)
//            }
//            let centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(myView.bounds), boxLocation.y - CGRectGetMidY(myView.bounds));
//            attachmentBehavior = UIAttachmentBehavior(item: myView, offsetFromCenter: centerOffset, attachedToAnchor: location)
//            attachmentBehavior.frequency = 0
//            
//            animator.addBehavior(attachmentBehavior)
//        } else if sender.state == UIGestureRecognizerState.Changed {
//            attachmentBehavior.anchorPoint = location
//        } else if sender.state == UIGestureRecognizerState.Ended {
//            animator.removeBehavior(attachmentBehavior)
//            
//            snapBehavior = UISnapBehavior(item: myView, snapToPoint: view.center)
//            animator.addBehavior(snapBehavior)
//            
//            let translation = sender.translationInView(view)
//            if translation.y > 100 {
//                animator.removeAllBehaviors()
//                
//                let gravity = UIGravityBehavior(items: [ideaView])
//                gravity.gravityDirection = CGVectorMake(0, 10)
//                animator.addBehavior(gravity)
//                
//                delay(1) {
//                    self.refreshView()
//                }
//            }
//        }
//    }
    
    // MARK: - Helper
    
    func delay(delay: Double, closure:() -> ()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func refreshView() {
        
        animator.removeAllBehaviors()
        
//        ideaView =
        
//        snapBehavior = UISnapBehavior(item: ideaView, snapToPoint: view.center)
//        attachmentBehavior.anchorPoint = view.center
        
//        ideaViewCenterY.constant = CGFloat(500)
//        ideaView.center = view.center
        viewDidAppear(true)
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
