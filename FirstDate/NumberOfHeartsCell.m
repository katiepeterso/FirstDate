//
//  NumberOfHeartsCell.m
//  FirstDate
//
//  Created by Katherine Peterson on 2015-09-24.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "NumberOfHeartsCell.h"
#import "DateIdea.h"

@interface NumberOfHeartsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *heartImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfHeartsLabel;
@property (nonatomic) DateIdea *selectedDateIdea;

@end

@implementation NumberOfHeartsCell

- (void)setup {
    
//    [[User currentUser].photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        if (!error) {
//            self.authorImageView.image = [UIImage imageWithData:data];
//        }
//    }];
//    
//    self.authorUsernameButton.titleLabel.text = [User currentUser].username;
//    self.dateDescriptionLabel.text = self.selectedDateIdea.description;
}


- (void)awakeFromNib {
    // Initialization code
    [self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDateIdea:(DateIdea *)dateIdea {
    _selectedDateIdea = dateIdea;
    
    [self setup];
}


@end
