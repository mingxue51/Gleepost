//
//  GLPTaskOperation.h
//  Gleepost
//
//  Created by Silouanos on 18/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"

@protocol PostUploaderDelegate;


@interface GLPPostOperation : NSOperation

@property(nonatomic, assign) id <PostUploaderDelegate> delegate;

@property (nonatomic, readonly, strong) NSIndexPath *campusWallIndexpath;
@property (nonatomic, readonly, strong) GLPPost *incomingPost;


-(id)initWithPost:(GLPPost*)post;

@end


@protocol PostUploaderDelegate <NSObject>

- (void)postUploaderDidFinish:(GLPPost *)uploadedPost;

@end