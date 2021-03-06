//
//  DateView.swift
//  FirstDate
//
//  Created by Alp Eren Can on 04/10/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit

@objc protocol DateViewDelegate {
    func dateViewShouldHeart(dateView: DateView) -> Bool
    func dateViewDidHeart(dateView: DateView)
    optional func dateViewDidUnheart(dateView: DateView)
}

class DateView: UIView {
    
    // MARK: Properties & Outlets
    
    weak var delegate: DateViewDelegate!
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var dateImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var heartCountLabel: UILabel!
    
    var idea: DateIdea? {
        didSet {
            
            guard let i = idea else {
                return
            }
            
            dateTitleLabel.text = i.title ?? ""
            usernameLabel.text = i.user?.username
        }
    }
    
    var hearted: Bool = false {
        didSet {
            if hearted {
                heartButton.setImage(UIImage(named: "hearted"), forState: .Normal)
            } else {
                heartButton.setImage(UIImage(named: "heart"), forState: .Normal)
            }
        }
    }
    
    var heartCount: Int = 0 {
        didSet {
            if heartCount != 0 {
                heartCountLabel.text = "\(heartCount)"
            }
        }
    }
    
    func setup() {
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        layer.cornerRadius = frame.height / 24.0
        heartCountLabel.text = " "
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    @IBAction func heart(button: UIButton) {
        if (delegate.dateViewShouldHeart(self)) {
            heartCount++
            button.setImage(UIImage(named: "hearted"), forState: .Normal)
            delegate.dateViewDidHeart(self)
            if (idea != nil) {
                PushNotificationHelper.pushNotificationTo(idea!.user, withMessage: "Your idea, '\(idea!.title)' has been hearted by \(User.currentUser()!.username!)")
            }
        }
    }
}