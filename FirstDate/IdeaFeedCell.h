//
//  IdeaFeedCell.h
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateIdea.h"

@class IdeaFeedCell;

@protocol FeedCellDelegate <NSObject>

- (void)showAlertController:(UIAlertController *)alertController;
- (void)performSegueWithIdentifier:(NSString *)identifier fromCell:(IdeaFeedCell *)cell;

@end

@interface IdeaFeedCell : UITableViewCell

@property (nonatomic, strong) DateIdea *dateIdea;
@property (nonatomic, weak) id<FeedCellDelegate> delegate;

@end
