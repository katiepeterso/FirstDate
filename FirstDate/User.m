//
//  User.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithUsername:(NSString *)username sex:(Sex)sex datingPreference:(DatingPreference)datingPreference
{
    self = [super init];
    if (self) {
        self.username = username;
        self.sex = sex;
        self.datingPreference = datingPreference;
        self.ideas = [NSMutableArray array];
        self.hearts = [NSMutableSet set];
    }
    return self;
}

@end
