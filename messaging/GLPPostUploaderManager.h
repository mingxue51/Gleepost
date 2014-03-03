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

@end
