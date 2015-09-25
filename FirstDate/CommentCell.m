//
//  CommentCell.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "CommentCell.h"
#import "DateIdea.h"
#import "FirstDate-Swift.h"

@interface CommentCell ()

@property (weak, nonatomic) IBOutlet UIButton *commenterUsernameButton;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (nonatomic) DateIdea *selectedDateIdea;
@property (nonatomic) Comment *currentComment;

@end

@implementation CommentCell

- (void)setup {
    
    self.commentLabel.text = self.currentComment.content;
    if (self.currentComment) {
        PFQuery *getAuthor = [PFUser query];
        [getAuthor getObjectInBackgroundWithId:self.currentComment.user.objectId block:^(PFObject *object, NSError *error){
            User *currentUser = (User *) object;
            [self.commenterUsernameButton setTitle:currentUser.username forState:UIControlStateNormal];
        }];
    }
}


- (void)awakeFromNib {
//    [self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDateIdea:(DateIdea *)dateIdea andComment:(Comment *)currentComment {
    _selectedDateIdea = dateIdea;
    _currentComment = currentComment;
    
    [self setup];
}


@end
