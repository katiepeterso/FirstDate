//
//  IdeaFeedCell.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "IdeaFeedCell.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>

@interface IdeaFeedCell ()

@property (nonatomic, weak) IBOutlet UIImageView *dateImageView;
@property (nonatomic, weak) IBOutlet UILabel *dateTitleLabel;
@property (nonatomic, weak) IBOutlet UIButton *heartButton;

@end

@implementation IdeaFeedCell

- (void)setup {
    
    [self.dateIdea.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.dateImageView.image = [UIImage imageWithData:data];
        }
    }];
    
    self.dateTitleLabel.text = self.dateIdea.title;
    
//    PFQuery *query = [PFQuery queryWithClassName:@"HeartedDateIdea"];
//    [query whereKey:@"user" equalTo:[User currentUser]];
//    [query whereKey:@"dateIdea" equalTo:self.dateIdea];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
//        if (results.count) {
//            [self.heartButton setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
//        } else {
//            [self.heartButton setImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateNormal];
//        }
//    }];
    
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
