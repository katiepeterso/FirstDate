//
//  User.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "User.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@implementation User
+ (void)load {
    [self registerSubclass];
}

@dynamic sex;
@dynamic datingPreference;
@dynamic age;
@dynamic name;
@dynamic photoFile;
@dynamic about;

- (instancetype)initWithUsername:(NSString *)username sex:(Sex)sex datingPreference:(DatingPreference)datingPreference
{
    self = [super init];
    if (self) {
        self.username = username;
        self.sex = sex;
        self.datingPreference = datingPreference;
    }
    return self;
}

@end
