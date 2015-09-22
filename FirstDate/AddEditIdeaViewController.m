//
//  AddEditIdeaViewController.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "AddEditIdeaViewController.h"
#import "DateIdea.h"
#import "AppDelegate.h"
#import "User.h"

@interface AddEditIdeaViewController ()

@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionView;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *photoLabel;
@property (strong, nonatomic) IBOutlet UIButton *submitEditButton;
@property (nonatomic, strong) DateIdea *currentDateIdea;
@property (nonatomic, assign) BOOL imageIsPicked;

@end

@implementation AddEditIdeaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageIsPicked = NO;
    self.photoLabel.text = @"Select date photo";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

//- (IBAction)markComplete:(UIButton *)sender {
//    
//    if (self.completionButtonChecked) {
//        [self.addNewCompletionButton setTitle:@"\u2610" forState:UIControlStateNormal];
//        self.completionButtonChecked = NO;
//    }
//    else {
//        [self.addNewCompletionButton setTitle:@"\u2611" forState:UIControlStateNormal];
//        self.completionButtonChecked = YES;
//    }
//}

- (IBAction)submitIdea:(UIButton *)sender {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.currentDateIdea = [[DateIdea alloc]initWithUser:appDelegate.currentUser title:self.titleField.text details:self.descriptionView.text];
    self.currentDateIdea.photo = self.photoImageView.image;
    
    [appDelegate.ideas addObject:self.currentDateIdea];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
