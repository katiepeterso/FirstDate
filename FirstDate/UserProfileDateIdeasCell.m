//
//  UserProfileDateIdeasCell.m
//  FirstDate
//
//  Created by Katherine Peterson on 2015-09-25.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "UserProfileDateIdeasCell.h"
#import "DateIdea.h"
#import "FirstDate-Swift.h"
#import "Heart.h"

@interface UserProfileDateIdeasCell ()

@property (weak, nonatomic) IBOutlet UIImageView *dateIdeaImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateIdeaLabel;

@end

@implementation UserProfileDateIdeasCell

- (void)setupForDate:(DateIdea *)date {
    
    self.layer.cornerRadius = self.frame.size.height / 12.0;
    self.layer.masksToBounds = true;
    
    self.dateIdeaLabel.text = date.title;
    
    self.dateIdeaImageView.image = nil;
    [PhotoHelper getPhotoInBackground:date.photo completionHandler:^(UIImage *datePhoto) {
        if ([date.objectId isEqualToString:self.currentDateIdea.objectId] ) {
            self.dateIdeaImageView.image = datePhoto;
        }
        
    }];
}

- (void)setDateIdea:(DateIdea *)dateIdea {
    _currentDateIdea = dateIdea;
    
    [self setupForDate:self.currentDateIdea];
}

- (void)setHeart:(Heart *)heart {
    _currentHeart = heart;
    [self setupForDate:self.currentHeart.dateIdea];
}


@end
