//
//  UserProfileDateIdeasCell.h
//  FirstDate
//
//  Created by Katherine Peterson on 2015-09-25.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DateIdea;
//@class Heart;

@interface UserProfileDateIdeasCell : UICollectionViewCell

@property (nonatomic) DateIdea *currentDateIdea;
//@property (nonatomic) Heart *currentHeart;

- (void)setDateIdea:(DateIdea *)dateIdea;
//- (void)setHeart:(Heart *)heart;

@end
