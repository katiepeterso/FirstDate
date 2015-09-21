//
//  Comment.h
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Comment : NSObject

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *timeStamp;

- (instancetype)initWithUser:(User *)user content:(NSString *)content;

@end
