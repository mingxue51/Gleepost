//
//  GLPPostUploaderManager.h
//  Gleepost
//
//  Created by Silouanos on 20/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"
#import "GLPComment.h"

@interface GLPPostUploaderManager : NSObject

-(void)addPost:(GLPPost*)post withTimestamp:(NSDate*)timestamp;
-(NSDictionary*)pendingPosts;
-(void)uploadPostWithTimestamp:(NSDate*)timestamp andImageUrl:(NSString*)url;
-(void)uploadTextPost:(GLPPost*)textPost;
-(void)addComment:(GLPComment *)comment;
-(NSArray *)getPendingCommentsWithPostKey:(int)postKey;
-(NSDate *)cancelPendingPostWithKey:(int)postKey;
//-(void)uploadPostWithTimestamp:(NSDate*)timestamp andVideoUrl:(NSString*)url;
-(void)uploadPostWithTimestamp:(NSDate*)timestamp andVideoId:(NSNumber *)videoId;
- (void)prepareVideoPostForUploadWithTimestamp:(NSDate *)timestamp andVideoId:(NSNumber *)videoId;
- (void)uploadPostWithVideoData:(NSDictionary *)videoData;
- (void)uploadVideoPost:(GLPPost *)videoPost;
- (BOOL)isVideoProcessed;
@end
