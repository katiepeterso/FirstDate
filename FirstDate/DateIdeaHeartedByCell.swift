//
//  DateIdeaHeartedByCell.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-12.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit

class DateIdeaHeartedByCell: UITableViewCell {
    
    var user: User? {
        didSet {
            setup()
        }
    }
    
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var usernameLabelLeading: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup() {
        PhotoHelper.makeCircleImageView(userPhotoImageView)
        if user != nil {
            usernameLabel.text = user?.username
            PhotoHelper.getPhotoInBackground(user?.userPhoto, completionHandler: { (resultImage) -> Void in
                self.userPhotoImageView.image = resultImage
            })
        }
    }

}
