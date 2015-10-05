//
//  IdeaView.swift
//  FirstDate
//
//  Created by Alp Eren Can on 04/10/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit

class IdeaView: UIView {
    
    // MARK: Properties & Outlets
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var dateImageView: UIImageView!
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var heartCountLabel: UILabel!
    
    var dateIdea: DateIdea? {
        didSet {
            dateTitleLabel.text = dateIdea?.title ?? ""
            usernameLabel.text = dateIdea?.user.username
            
        }
    }
    
    func setup() {
        layer.cornerRadius = frame.height / 24.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
}
