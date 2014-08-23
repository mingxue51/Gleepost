//
//  GLPProgressManager.h
//  Gleepost
//
//  Created by Σιλουανός on 22/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UploadingProgressView;

@interface GLPProgressManager : NSObject

+ (GLPProgressManager *)sharedInstance;

- (void)registerVideoWithTimestamp:(NSDate *)timestamp;
- (UploadingProgressView *)progressView;
- (void)setThumbnailImage:(UIImage *)thumbnail;
- (void)progressFinished;

@end
