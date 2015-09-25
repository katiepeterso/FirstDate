    //
//  IdeaFeedCell.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "IdeaFeedCell.h"
#import <UIKit/UIKit.h>
#import "IdeasFeedViewController.h"
#import "IdeaDetailViewController.h"
#import "FirstDate-Swift.h"
#import "Heart.h"

@interface IdeaFeedCell ()

@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) NSMutableArray *hearts;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic) BOOL hasFetched;

@property (nonatomic, weak) IBOutlet UIImageView *dateImageView;
@property (nonatomic, weak) IBOutlet UILabel *dateTitleLabel;
@property (nonatomic, weak) IBOutlet UIButton *heartButton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet UILabel *heartCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentCountLabel;
@property (nonatomic, weak) IBOutlet UIButton *editButton;

@end

@implementation IdeaFeedCell

- (void)setup {
    
    self.currentUser = [User currentUser];
    if ([self.dateIdea.user isEqual:self.currentUser]) {
        self.editButton.hidden = NO;
    }
    
    [self.dateIdea.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.dateImageView.image = [UIImage imageWithData:data];
        }
    }];
    
    self.dateTitleLabel.text = self.dateIdea.title;
    
}

- (void)setDateIdea:(DateIdea *)dateIdea {
    _dateIdea = dateIdea;
    self.hearts = [NSMutableArray array];
    
    [self fetchCellData];
    
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
    
    if (!self.hasFetched) {
        return;
    }
    
    self.hasFetched = NO;
    BOOL heartedBefore = NO;
    
    for (Heart *heart in self.hearts) {
        if ([heart.user.objectId isEqualToString:self.currentUser.objectId]) {
            heartedBefore = YES;
            [self.heartButton setImage:[UIImage imageNamed:@"heart"] forState: UIControlStateNormal];
            self.heartCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.hearts.count - 1];
            [heart deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self fetchCellData];
            }];
            return;
        }
    }
    
    if (!heartedBefore) {
        Heart *currentHeart = [[Heart alloc] initWithUser:self.currentUser dateIdea:self.dateIdea];
        [self.heartButton setImage:[UIImage imageNamed:@"hearted"] forState: UIControlStateNormal];
        self.heartCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.hearts.count + 1];
        [currentHeart saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self fetchCellData];
        }];
    }
    
}

- (IBAction)comment:(UIButton *)commentButton {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter a comment" message:@"Please be respectful!" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Your comment goes here...";
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { }]];
    
    UITextField *commentTextField = alertController.textFields[0];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        Comment *comment = [[Comment alloc] initWithUser:self.currentUser dateIdea:self.dateIdea content:commentTextField.text];
        [self.delegate performSegueWithIdentifier:@"showDetail" fromCell:self];
        [comment pinInBackground];
        [comment saveInBackground];
        
    }]];
    
    [self.delegate showAlertController:alertController];
}

- (void)fetchCellData {
    
    self.hasFetched = NO;
    PFQuery *heartQuery = [PFQuery queryWithClassName:@"Heart"];
    [heartQuery whereKey:@"dateIdea" equalTo:self.dateIdea];
    [heartQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            self.hearts = [results mutableCopy];
            self.heartCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.hearts.count];
            
            for (Heart *heart in self.hearts) {
                
                if ([heart.user.objectId isEqualToString:self.currentUser.objectId]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.heartButton setImage:[UIImage imageNamed:@"hearted"] forState: UIControlStateNormal];
                    });
                    break;
                }
            }
        } else {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops! Something went wrong." message:[NSString stringWithFormat:@"%@", error.description] preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }]];
            
            [self.delegate showAlertController:alertController];
        }
        
        self.hasFetched = YES;
    }];
    
    PFQuery *commentQuery = [PFQuery queryWithClassName:@"Comment"];
    [commentQuery whereKey:@"dateIdea" equalTo:self.dateIdea];
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            self.comments = [results mutableCopy];
            self.commentCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.comments.count];
        } else {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops! Something went wrong." message:[NSString stringWithFormat:@"%@", error.description] preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }]];
            
            [self.delegate showAlertController:alertController];
        }
    }];
    
}

@end
