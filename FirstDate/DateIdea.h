//
//  DateIdea.h
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface DateIdea : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *details;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSMutableSet *hearts;
@property (nonatomic, strong) NSDate *timeStamp;

- (instancetype)initWithUser:(User *)user title:(NSString*) title details:(NSString *)details;

@end
