//
//  GLPGroupProgressManager.h
//  Gleepost
//
//  Created by Silouanos on 26/09/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UploadingProgressView.h"

@class GLPPost;

@interface GLPGroupProgressManager : NSObject

- (void)registerVideoWithTimestamp:(NSDate *)timestamp withPost:(GLPPost *)post;
- (UploadingProgressView *)progressView;
- (NSDate *)registeredTimestamp;
- (void)setThumbnailImage:(UIImage *)thumbnail;
- (void)progressFinished;
- (void)postButtonClicked;
- (BOOL)isProgressFinished;
- (NSInteger)postRemoteKey;
- (NSString *)generateNSNotificationNameForPendingGroupPost;

@end
