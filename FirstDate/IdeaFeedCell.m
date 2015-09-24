//
//  IdeaFeedCell.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "IdeaFeedCell.h"
#import <UIKit/UIKit.h>
#import "FirstDate-Swift.h"
#import "Heart.h"

@interface IdeaFeedCell ()

@property (nonatomic, strong) User *currentUser;

@property (nonatomic, weak) IBOutlet UIImageView *dateImageView;
@property (nonatomic, weak) IBOutlet UILabel *dateTitleLabel;
@property (nonatomic, weak) IBOutlet UIButton *heartButton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet UILabel *heartCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end

@implementation IdeaFeedCell

- (void)setup {
    
    self.currentUser = [User currentUser];
    
    [self.dateIdea.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.dateImageView.image = [UIImage imageWithData:data];
        }
    }];
    
    if ([self.dateIdea.user isEqual:self.currentUser]) {
        self.editButton.hidden = NO;
    }
    
    self.dateTitleLabel.text = self.dateIdea.title;
    
}

- (void)setDateIdea:(DateIdea *)dateIdea {
    _dateIdea = dateIdea;
    
    [self setup];
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)hearted:(UIButton *)heartbutton {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Heart"];
    [query whereKey:@"user" equalTo:self.currentUser];
    [query whereKey:@"dateIdea" equalTo:self.dateIdea];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            if (results.count) {
                [self.heartButton setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
                [results[0] deleteInBackground];
                
            } else {
                Heart *currentHeart = [[Heart alloc] initWithUser:self.currentUser dateIdea:self.dateIdea];
                [self.heartButton setImage:[UIImage imageNamed:@"heart_selected"] forState: UIControlStateNormal];
                [currentHeart saveInBackground];
            }
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops! Something went wrong."
                                                                message:@"You may be hearing an idea that is already been deleted."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        }
        
    }];
    
}

- (IBAction)comment:(UIButton *)commentButton {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter a comment" message:@"Please be respectful!" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Your comment goes here...";
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    UITextField *commentTextField = alertController.textFields[0];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        Comment *comment = [[Comment alloc] initWithUser:self.currentUser dateIdea:self.dateIdea content:commentTextField.text];
        [comment pinInBackground];
        [comment saveInBackground];
        
    }]];
    
    [self.delegate showAlertController:alertController];
}


@end
