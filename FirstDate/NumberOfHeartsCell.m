//
//  NumberOfHeartsCell.m
//  FirstDate
//
//  Created by Katherine Peterson on 2015-09-24.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "NumberOfHeartsCell.h"
#import "DateIdea.h"
#import "Heart.h"

@interface NumberOfHeartsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *heartImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfHeartsLabel;
@property (nonatomic) DateIdea *selectedDateIdea;

@end

@implementation NumberOfHeartsCell

- (void)setup {
    if (self.selectedDateIdea) {
        PFQuery *getHearts = [PFQuery queryWithClassName:@"Heart"];
        [getHearts whereKey:@"dateIdea" equalTo:self.selectedDateIdea];
        [getHearts findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if (results.count==0) {
                self.numberOfHeartsLabel.text = @"";
                self.heartImageView.image = [UIImage imageNamed:@"heart"];
            }else {
                self.numberOfHeartsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)results.count];
            }
        }];
    }
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
