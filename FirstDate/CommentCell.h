//
//  CommentCell.h
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Comment;
@class DateIdea;

@interface CommentCell : UITableViewCell

- (void)setDateIdea:(DateIdea *)dateIdea andComment:(Comment *)currentComment;

@end
