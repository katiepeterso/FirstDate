//
//  DateIdea.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "DateIdea.h"

@implementation DateIdea

+ (void)load {
    [self registerSubclass];
}

@dynamic user;
@dynamic title;
@dynamic details;
@dynamic heartedBy;
@dynamic photo;
@dynamic messages;

+ (NSString *)parseClassName {
    return @"DateIdea";
}

- (instancetype)initWithUser:(User *)user title:(NSString*)title details:(NSString *)details
{
    self = [super init];
    if (self) {
        self.user = user;
        self.title = title;
        self.details = details;
    }
    return self;
}

@end
