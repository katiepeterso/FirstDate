//
//  PhotoRecord.m
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-19.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "PhotoRecord.h"

@implementation PhotoRecord

- (BOOL)hasImage {
    return _image != nil;
}


- (BOOL)isFailed {
    return _failed;
}


- (BOOL)isFiltered {
    return _filtered;
}

@end
