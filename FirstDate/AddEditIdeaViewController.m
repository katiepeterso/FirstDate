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
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

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
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideKeyboard)];
    
    [accessoryView setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], done]];
    
    self.titleField.inputAccessoryView = accessoryView;
    self.descriptionView.inputAccessoryView = accessoryView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Image Picker and display

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.delegate = self;
        pickerController.mediaTypes = @[(__bridge NSString *)kUTTypeImage];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:pickerController animated:YES completion:nil];
            
        }]];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [alertController addAction:[UIAlertAction actionWithTitle:@"Take Photo or Video" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:pickerController animated:YES completion:nil];
                
            }]];
        }
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.photoImageView.image = info[UIImagePickerControllerOriginalImage];
    
    if (!self.currentDateIdea) {
        self.currentDateIdea = [[DateIdea alloc]init];
    }
    
    NSData* data = UIImageJPEGRepresentation(self.photoImageView.image, 0.25);
    self.currentDateIdea.photo = [PFFile fileWithData:data];
    [self.currentDateIdea.photo saveInBackground];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.photoLabel.text = @"Change date photo";
}

#pragma mark - Submit new idea

- (IBAction)submitIdea:(UIButton *)sender {
    
    if (!self.currentDateIdea) {
        self.currentDateIdea = [[DateIdea alloc]initWithUser:[User currentUser] title:self.titleField.text details:self.descriptionView.text];
    } else {
        self.currentDateIdea.title = self.titleField.text;
        self.currentDateIdea.details = self.descriptionView.text;
    }
    
    self.currentDateIdea.user = [User currentUser];
    
    [self.currentDateIdea pinInBackgroundWithName:USER_DATA_PINNING_LABEL];
    [self.currentDateIdea saveEventually];
    
    [self.tabBarController setSelectedIndex:0];
    self.photoLabel.text = @"Select date photo";
    self.titleField.text = @"";
    self.descriptionView.text = @"Enter date description here...";
    self.descriptionView.textColor = [UIColor lightGrayColor];
    self.photoImageView.image = [UIImage imageNamed:@"placeholder.png"];
    self.currentDateIdea = nil;
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
    [self hideKeyboard];
}

#pragma mark - Text Edit Resign First Responder
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hideKeyboard];
    return YES;
}

- (void)hideKeyboard {
    [self.titleField resignFirstResponder];
    [self.descriptionView resignFirstResponder];
}

@end
