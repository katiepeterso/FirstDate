//
//  CommentCell.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "CommentCell.h"
#import "DateIdea.h"

@interface CommentCell ()

@property (weak, nonatomic) IBOutlet UIButton *commenterUsernameButton;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (nonatomic) DateIdea *selectedDateIdea;

@end

@implementation CommentCell

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
