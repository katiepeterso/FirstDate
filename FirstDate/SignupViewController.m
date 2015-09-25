//
//  SingupViewController.m
//  Ribbit
//
//  Created by Alp Eren Can on 20/04/14.
//  Copyright (c) 2014 Alp Eren Can. All rights reserved.
//

#import "SignupViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>
#import "User.h"

@interface SignupViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *ageField;

@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.emailField.delegate = self;
    self.ageField.delegate = self;
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideKeyboard)];
    done.tintColor = [UIColor colorWithRed:80.0/255.0 green:210.0/255.0 blue:194.0/255.0 alpha:1.0];
    
    [accessoryView setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], done]];
    
    self.ageField.inputAccessoryView = accessoryView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self subscribeToKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unsubscribeToKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

#pragma mark - Image Picker and display
- (IBAction)profilePhotoTapped:(UITapGestureRecognizer *)sender {
    
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.photoImageView.image = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signup:(id)sender
{
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *age = [self.ageField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    if ([username length] == 0 || [password length] == 0 || [email length] == 0 || [age length] == 0 || !self.photoImageView.image ) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops! Something went wrong."
                                                                                 message:@"Make sure you provide a photo, enter a username, password, email address and your age!"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        User *newUser = [User user];
        newUser.username = username;
        newUser.password = password;
        newUser.email = email;
        newUser.age = [age intValue];
        
        if (self.photoImageView.image) {
            NSData* data = UIImageJPEGRepresentation(self.photoImageView.image, 0.25);
            newUser.photo = [PFFile fileWithData:data];
        }
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops! Something went wrong."
                                                                                         message:[NSString stringWithFormat:@"%@", error.description]
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
    
}

- (IBAction)dismiss:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    frame.origin.y = -[self getKeyboardHeight:notification] / 2;
    self.view.frame = frame;

}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    frame.origin.y = 0;
    self.view.frame = frame;
}

- (CGFloat)getKeyboardHeight:(NSNotification *)notification {
    NSValue *keyboardSize = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    return keyboardSize.CGRectValue.size.height;
}

- (void)subscribeToKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unsubscribeToKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
                                                                                                          
- (void)hideKeyboard {
    [self.ageField resignFirstResponder];
}
                                                                                                          
#pragma mark Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
