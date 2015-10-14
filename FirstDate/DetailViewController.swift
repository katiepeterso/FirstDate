//
//  DetailViewController.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-07.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var detailIdeaImageView: UIImageView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var messageButtonTrailing: NSLayoutConstraint!
    @IBOutlet weak var heartCountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var idea: DateIdea!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.transform = CGAffineTransformMakeScale(0.0, 0.0)
        backButtonLeading.constant = -100
        
        messageButton.transform = CGAffineTransformMakeScale(0.5, 0.5)
        messageButtonTrailing.constant = +100
        
        setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: { () -> Void in
            self.backButton.transform = CGAffineTransformMakeScale(1, 1)
            self.backButtonLeading.constant = 0
            
            if (self.idea.user == User.currentUser()) {
                self.messageButton.transform = CGAffineTransformMakeScale(1, 1)
                self.messageButtonTrailing.constant = 0
            }
            }, completion: nil)
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showHeartedBy" {
            let heartedVC = segue.destinationViewController as! DateIdeaHeartedByViewController
            heartedVC.idea = self.idea
        }
    }
    
    func setup() {
        if (idea != nil) {
            PhotoHelper.getPhotoInBackground(idea.photo) { (resultImage) -> Void in
                self.detailIdeaImageView.image = resultImage
            }
            
            if let user = idea.user,
                let photo = user.userPhoto {
                    PhotoHelper.getPhotoInBackground(photo) { (resultImage) -> Void in
                        self.profileImageView.image = resultImage
                    }
                    
            }
            
            let query = idea.heartedBy.query()
            query?.countObjectsInBackgroundWithBlock({ (result, error) -> Void in
                if error == nil {
                    self.heartCountLabel.text = "\(result)"
                    if (result < 1) {
                        self.messageButton.enabled = false
                        self.messageButton.alpha = 0.0
                    } else {
                        self.messageButton.enabled = true
                        self.messageButton.alpha = 1.0
                    }
                }
            })
            
            usernameLabel.text = idea.user.username
            descriptionLabel.text = idea.details
            titleLabel.text = idea.title
            PhotoHelper.makeCircleImageView(profileImageView)

        }
    }

}
