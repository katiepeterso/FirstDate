//
//  DateIdea.m
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "DateIdea.h"

@implementation DateIdea

- (instancetype)initWithUser:(User *)user title:(NSString*)title details:(NSString *)details
{
    self = [super init];
    if (self) {
        self.user = user;
        self.title = title;
        self.details = details;
        self.comments = [NSMutableArray array];
        self.hearts = [NSMutableSet set];
        self.timeStamp = [NSDate date];
        self.photo = [UIImage imageNamed:@"placeholder.png"];
    }
    return self;
}

@end
