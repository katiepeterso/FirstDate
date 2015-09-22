//
//  IdeaFeedCell.h
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateIdea.h"
@interface IdeaFeedCell : UITableViewCell

@property (nonatomic, strong) DateIdea *dateIdea;

- (void)setup;

@end
