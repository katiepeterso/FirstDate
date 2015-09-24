//
//  IdeaFeedCell.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "IdeaFeedCell.h"
#import "AppDelegate.h"

@interface IdeaFeedCell ()

@property (nonatomic, weak) IBOutlet UIImageView *dateImageView;
@property (nonatomic, weak) IBOutlet UILabel *dateTitleLabel;
@property (nonatomic, weak) IBOutlet UIButton *heartButton;

@end

@implementation IdeaFeedCell

- (void)setup {
    
//    self.dateImageView.image = self.dateIdea.photo; // TODO: Get image from file
    
    self.dateTitleLabel.text = self.dateIdea.title;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    User *currentUser = [User currentUser];
    
//    if ([self.dateIdea.hearts containsObject:currentUser]) {
//        [self.heartButton setImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateNormal];
//    } else {
//        [self.heartButton setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
//    }
}

- (void)setDateIdea:(DateIdea *)dateIdea {
    _dateIdea = dateIdea;
    
    [self setup];
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
