//
//  LoginViewController.m
//  Ribbit
//
//  Created by Alp Eren Can on 20/04/14.
//  Copyright (c) 2014 Alp Eren Can. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"
#import <Parse/Parse.h>

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginFormBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonTop;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self subscribeToKeyboardNotifications];

    [self.navigationController.navigationBar setHidden:YES];
    
    // Disable back swipe gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unsubscribeToKeyboardNotifications];
}

- (IBAction)login:(id)sender
{
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops! Something went wrong."
                                                                                 message:@"Make sure you enter a username and password!"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else {
        [User logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops! Something went wrong."
                                                                                         message:[NSString stringWithFormat:@"%@", error.description]
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
                
            } else {
                [self.delegate loginViewController:self didLoginUser:(User *)user];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [UIView animateWithDuration:0.25 animations:^{
        [self.view removeConstraint:self.cancelButtonTop];
        self.loginFormBottom.constant = [self getKeyboardHeight:notification] + 16;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.25 animations:^{
        self.cancelButtonTop = [self.cancelButton.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor constant:8.0];
        [self.view addConstraint:self.cancelButtonTop];
        self.loginFormBottom.constant = 16;
        [self.view layoutIfNeeded];
    }];
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

#pragma mark Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
