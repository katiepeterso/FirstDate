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
}

class DateView: UIView {
    
    // MARK: Properties & Outlets
    
    var hearted: Bool = false {
        didSet {
            heartButton.setImage(UIImage(named: "hearted"), forState: .Normal)
        }
    }
    
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
    
    func setup() {
        layer.cornerRadius = frame.height / 24.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    @IBAction func hearted(button: UIButton) {
        if (delegate.dateViewShouldHeart(self)) {
            button.setImage(UIImage(named: "hearted"), forState: .Normal)
            delegate.dateViewDidHeart(self)
        }
    }
}
