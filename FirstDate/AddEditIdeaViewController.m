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
#import <MobileCoreServices/MobileCoreServices.h>

@interface AddEditIdeaViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate>

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
    
    self.titleField.text = @"";
    self.titleField.delegate = self;
    
    self.descriptionView.text = @"Enter date description here...";
    self.descriptionView.textColor = [UIColor lightGrayColor];
    self.descriptionView.delegate = self;
    
    self.photoImageView.image = [UIImage imageNamed:@"placeholder.png"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 4;
//}

#pragma mark - Image Picker and display

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerController.delegate = self;
        pickerController.mediaTypes = @[(__bridge NSString *)kUTTypeImage];
        [self presentViewController:pickerController animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.photoImageView.image = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.photoLabel.text = @"Change date photo";
}


#pragma mark - Submit new idea

- (IBAction)submitIdea:(UIButton *)sender {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.currentDateIdea = [[DateIdea alloc]initWithUser:appDelegate.currentUser title:self.titleField.text details:self.descriptionView.text];
    self.currentDateIdea.photo = self.photoImageView.image;
    
    [appDelegate.ideas addObject:self.currentDateIdea];
    
    [self.tabBarController setSelectedIndex:0];
    self.photoLabel.text = @"Select date photo";
    self.titleField.text = @"";
    self.descriptionView.text = @"";
    self.photoImageView.image = [UIImage imageNamed:@"placeholder.png"];
}

#pragma mark - Text view placeholder

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Enter date description here..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Enter date description here...";
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
