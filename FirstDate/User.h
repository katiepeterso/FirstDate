//
//  User.h
//  FirstDate
//
//  Created by Alp Eren Can on 21/09/15.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, Sex) {
    SexMale,
    SexFemale,
};

typedef NS_ENUM(NSUInteger, DatingPreference) {
    DatingPreferenceMale,
    DatingPreferenceFemale,
    DatingPreferenceBoth,
};

@interface User : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, assign) Sex sex;
@property (nonatomic, assign) DatingPreference datingPreference;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSMutableArray *ideas;

- (instancetype)initWithUsername:(NSString *)username sex:(Sex)sex datingPreference:(DatingPreference)datingPreference;

@end
