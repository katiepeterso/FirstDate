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
    
    self.dateImageView.image = self.dateIdea.photo;
    self.dateTitleLabel.text = self.dateIdea.title;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    User *currentUser = appDelegate.currentUser;
    
    if ([currentUser.hearts containsObject:self.dateIdea]) {
        [self.heartButton setImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateSelected];
        [self.heartButton setSelected:YES];
    }
}

- (void)setDateIdea:(DateIdea *)dateIdea {
    if (!_dateIdea) {
        _dateIdea = dateIdea;
        [self setup];
    }
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
