//
//  ImageDownloader.m
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-19.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInCollectionView;
@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;
@end


@implementation ImageDownloader

#pragma mark - Life Cycle
- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)theDelegate {
    
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.indexPathInCollectionView = indexPath;
        self.photoRecord = record;
    }
    return self;
}

- (void)main {

    @autoreleasepool {
        
        if (self.isCancelled)
            return;
        
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.photoRecord.URL];
        
        if (self.isCancelled) {
            imageData = nil;
            return;
        }
        
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.photoRecord.image = downloadedImage;
        }
        else {
            self.photoRecord.failed = YES;
        }
        
        imageData = nil;
        
        if (self.isCancelled)
            return;
        
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
        
    }
}

@end
