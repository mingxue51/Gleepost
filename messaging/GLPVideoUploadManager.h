//
//  GLPVideoManager.h
//  Gleepost
//
//  Created by Silouanos on 13/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"

@interface GLPVideoUploadManager : NSObject

+ (GLPVideoUploadManager *)sharedInstance;

- (void)uploadVideo:(NSString*)videoPath withTimestamp:(NSDate*)timestamp;

- (void)setPost:(GLPPost *)post withTimestamp:(NSDate *)timestamp;

- (void)refreshVideoPostInCampusWallWithData:(NSDictionary *)data;

- (void)startCheckingForNonUploadedVideoPosts;

- (void)cancelVideoWithTimestamp:(NSDate *)timestamp;

@end
