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

@dynamic name;
@dynamic age;
@dynamic gender;
@dynamic datingPreference;
@dynamic about;
@dynamic coverPhoto;
@dynamic userPhoto;
@dynamic lastSeenDateIdeaCreatedAt;

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email
{
    self = [super init];
    if (self) {
        self.username = username;
        self.password = email;
        self.email = email;
    }
    return self;
}

@end
