//
//  UserProfileDateIdeasCell.m
//  FirstDate
//
//  Created by Katherine Peterson on 2015-09-25.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "UserProfileDateIdeasCell.h"
#import "DateIdea.h"

@interface UserProfileDateIdeasCell ()

@property (weak, nonatomic) IBOutlet UIImageView *dateIdeaImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateIdeaLabel;

@end

@implementation UserProfileDateIdeasCell

- (void)setup {
    
    self.dateIdeaLabel.text = self.currentDateIdea.title;
    if ([self.currentDateIdea.photo isDataAvailable]) {
        [self.currentDateIdea.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                self.dateIdeaImageView.image = [UIImage imageWithData:data];
            }
        }];
    }
}


- (void)awakeFromNib {
    //    [self setup];
}

- (void)setDateIdea:(DateIdea *)dateIdea {
    _currentDateIdea = dateIdea;
    
    [self setup];
}


@end
