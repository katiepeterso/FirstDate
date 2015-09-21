//
//  Comment.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (instancetype)initWithUser:(User *)user content:(NSString *)content
{
    self = [super init];
    if (self) {
        self.user = user;
        self.content = content;
        self.timeStamp = [NSDate date];
    }
    return self;
}

@end
