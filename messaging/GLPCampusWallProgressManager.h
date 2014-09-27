//
//  GLPProgressManager.h
//  Gleepost
//
//  Created by Σιλουανός on 22/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UploadingProgressView;
@class GLPPost;

@interface GLPCampusWallProgressManager : NSObject

+ (GLPCampusWallProgressManager *)sharedInstance;

- (void)registerVideoWithTimestamp:(NSDate *)timestamp withPost:(GLPPost *)post;
- (NSDate *)registeredTimestamp;
- (UploadingProgressView *)progressView;
- (void)setThumbnailImage:(UIImage *)thumbnail;
- (void)progressFinished;
- (void)postButtonClicked;
//- (BOOL)isProgressViewVisible;
- (BOOL)isProgressFinished;
//- (void)setPendingPost:(GLPPost *)post;

@end
