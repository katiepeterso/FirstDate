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
#import "FirstDate-Swift.h"

@interface SignupViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signupFormBottom;
@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nextButton.alpha = 0.5;
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.emailField.delegate = self;
    
//    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
//    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideKeyboard)];
//    done.tintColor = [UIColor colorWithRed:80.0/255.0 green:210.0/255.0 blue:194.0/255.0 alpha:1.0];
//    
//    [accessoryView setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], done]];
    
//    self.ageField.inputAccessoryView = accessoryView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self subscribeToSystemNotifications];
    [self validateForm];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unsubscribeFromSystemNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Enable back swipe gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (IBAction)dismiss:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Handle System Notifications

- (void)usernameChanged:(NSNotification *)notification {
    [self validateForm];
}

- (void)passwordChanged:(NSNotification *)notification {
    [self validateForm];
}

- (void)emailChanged:(NSNotification *)notification {
    [self validateForm];
}

- (void)validateForm {
    if (self.usernameField.text.length && self.passwordField.text.length && self.emailField.text.length) {
        self.nextButton.alpha = 1.0;
        self.nextButton.enabled = YES;
    } else {
        self.nextButton.alpha = 0.5;
        self.nextButton.enabled = NO;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [UIView animateWithDuration:0.25 animations:^{
        self.signupFormBottom.constant = [self getKeyboardHeight:notification] + 16;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.25 animations:^{
        self.signupFormBottom.constant = 16;
        [self.view layoutIfNeeded];
    }];
}

- (CGFloat)getKeyboardHeight:(NSNotification *)notification {
    NSValue *keyboardSize = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    return keyboardSize.CGRectValue.size.height;
}

- (void)subscribeToSystemNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usernameChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passwordChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unsubscribeFromSystemNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)hideKeyboard {
//    [self.ageField resignFirstResponder];
//}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Navigation 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"continueSignUp"]) {
        NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        SignupSupplementViewController *supplementVC = segue.destinationViewController;
        supplementVC.username = username;
        supplementVC.password = password;
        supplementVC.email = email;
    }
}
@end
