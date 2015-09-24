//
//  HeartedDateIdea.h
//  FirstDate
//
//  Created by Katherine Peterson on 2015-09-23.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "User.h"
#import "DateIdea.h"

@interface HeartedDateIdea : PFObject <PFSubclassing>

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) DateIdea *dateIdea;

+ (NSString *)parseClassName;

@end
