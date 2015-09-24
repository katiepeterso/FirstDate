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

@interface IdeaDescriptionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *authorImageView;
@property (weak, nonatomic) IBOutlet UIButton *authorUsernameButton;
@property (weak, nonatomic) IBOutlet UILabel *dateDescriptionLabel;
@property (nonatomic) DateIdea *selectedDateIdea;

@end

@implementation IdeaDescriptionCell

- (void)setup {
    
    [[User currentUser].photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.authorImageView.image = [UIImage imageWithData:data];
        }
    }];
    
    [self.authorUsernameButton setTitle:[User currentUser].username forState:UIControlStateNormal];
    self.dateDescriptionLabel.text = self.selectedDateIdea.details;
}

- (void)setDateIdea:(DateIdea *)dateIdea {
    _selectedDateIdea = dateIdea;
    
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
