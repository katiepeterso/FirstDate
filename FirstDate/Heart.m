//
//  HeartedDateIdea.m
//  FirstDate
//
//  Created by Katherine Peterson on 2015-09-23.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "Heart.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@implementation Heart

@dynamic user;
@dynamic dateIdea;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Heart";
}

- (instancetype)initWithUser:(User *)user dateIdea:(DateIdea *)dateIdea
{
    self = [super init];
    if (self) {
        self.user = user;
        self.dateIdea = dateIdea;
    }
    return self;
}

@end
