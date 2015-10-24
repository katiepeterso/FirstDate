//
//  UserProfileDateIdeasCell.h
//  FirstDate
//
//  Created by Katherine Peterson on 2015-09-25.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DateIdea;

@interface UserProfileDateIdeasCell : UICollectionViewCell

@property (nonatomic) DateIdea *currentDateIdea;
@property (nonatomic) UIImage *downloadedImage;

- (void)setDateIdea:(DateIdea *)dateIdea;

@end
