//
//  DetailViewController.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-07.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailIdeaImageView: UIImageView!
    @IBOutlet weak var numberOfHeartsLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var detailIdea: DateIdea!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
    }
    
    func setup() {
        if (detailIdea != nil) {
            PhotoHelper.getPhotoInBackground(detailIdea.photo) { (resultImage) -> Void in
                self.detailIdeaImageView.image = resultImage
            }
            PhotoHelper.getPhotoInBackground(detailIdea.user.userPhoto) { (resultImage) -> Void in
                self.profileImageView.image = resultImage
            }
            self.usernameLabel.text = self.detailIdea.user.username
//            self.descriptionLabel.text = self.detailIdea.description
        }
    }

}
