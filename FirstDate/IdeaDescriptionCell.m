//
//  IdeaDescriptionCell.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "IdeaDescriptionCell.h"
#import "User.h"
#import "DateIdea.h"
#import "FirstDate-Swift.h"

@interface IdeaDescriptionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *authorImageView;
@property (weak, nonatomic) IBOutlet UIButton *authorUsernameButton;
@property (weak, nonatomic) IBOutlet UILabel *dateDescriptionLabel;
@property (nonatomic) DateIdea *selectedDateIdea;

@end

@implementation IdeaDescriptionCell

- (void)setup {
    
    self.dateDescriptionLabel.text = self.selectedDateIdea.details;
    __weak IdeaDescriptionCell* weakSelf = self;
    
    if (self.selectedDateIdea) {
        PFQuery *getAuthor = [PFUser query];
        [getAuthor getObjectInBackgroundWithId:self.selectedDateIdea.user.objectId block:^(PFObject *object, NSError *error){
            User *currentUser = (User *) object;
            [weakSelf.authorUsernameButton setTitle:currentUser.username forState:UIControlStateNormal];
            
            [PhotoHelper getPhotoInBackground:currentUser.userPhoto completionHandler:^(UIImage *userPhoto) {
                self.authorImageView.image = userPhoto;
            }];
        }];
    }
}

- (void)setDateIdea:(DateIdea *)dateIdea {
    _selectedDateIdea = dateIdea;
    
    [self setup];
}

- (void)awakeFromNib {
//
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
