//
//  DateIdea.h
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "User.h"

@interface DateIdea : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *details;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) PFFile *photo;

+ (NSString *)parseClassName;

- (instancetype)initWithUser:(User *)user title:(NSString*) title details:(NSString *)details;

@end
