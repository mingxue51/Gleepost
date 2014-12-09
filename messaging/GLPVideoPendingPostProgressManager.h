//
//  GLPVideoPendingPostProgressManager.h
//  Gleepost
//
//  Created by Silouanos on 08/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCWProgressManager.h"
@class GLPPost;

@interface GLPVideoPendingPostProgressManager : GLPCWProgressManager

+ (GLPVideoPendingPostProgressManager *)sharedInstance;
- (void)registerWithTimestamp:(NSDate *)timestamp withPost:(GLPPost *)post;
- (NSString *)generateNSNotificationNameForPendingPost;
- (NSString *)generateNSNotificationUploadFinshedNameForPendingPost;

@end
