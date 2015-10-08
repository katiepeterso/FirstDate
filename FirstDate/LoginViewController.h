//
//  LoginViewController.h
//  Ribbit
//
//  Created by Alp Eren Can on 20/04/14.
//  Copyright (c) 2014 Alp Eren Can. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;
@class User;

@protocol LoginViewControllerDelegate <NSObject>

-(void)loginViewController:(LoginViewController *)loginViewController didLoginUser:(User *)user;

@optional
-(void)loginViewControllerDidCancelLogin:(LoginViewController *)loginViewController;

@end

@interface LoginViewController : UIViewController <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<LoginViewControllerDelegate> delegate;

@end
