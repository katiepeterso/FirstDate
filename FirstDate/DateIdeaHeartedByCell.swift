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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup() {
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.size.width/2
        userPhotoImageView.clipsToBounds = true
        
        if user != nil {
            usernameLabel.text = user?.username
            if user?.userPhoto != nil {
                PhotoHelper.getPhotoInBackground((user?.userPhoto)!) { (resultImage) -> Void in
                    self.userPhotoImageView.image = resultImage
                }
            }
        }
    }

}
