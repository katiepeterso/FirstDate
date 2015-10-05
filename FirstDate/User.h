//
//  User.h
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@class PFFile;

typedef NS_ENUM(NSUInteger, Sex) {
    SexMale,
    SexFemale,
};

typedef NS_ENUM(NSUInteger, DatingPreference) {
    DatingPreferenceMale,
    DatingPreferenceFemale,
    DatingPreferenceBoth,
};

@interface User: PFUser <PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, assign) Sex sex;
@property (nonatomic, assign) DatingPreference datingPreference;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) PFFile *coverPhoto;
@property (nonatomic, strong) PFFile *userPhoto;

- (instancetype)initWithUsername:(NSString *)username sex:(Sex)sex datingPreference:(DatingPreference)datingPreference;

@end
