//
//  GLPTaskOperation.h
//  Gleepost
//
//  Created by Silouanos on 18/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"

typedef void (^viewCreator)(void);

@protocol PostUploaderDelegate;


@interface GLPPostOperation : NSOperation

@property(nonatomic, assign) id <PostUploaderDelegate> delegate;

@property (nonatomic, readonly, strong) NSIndexPath *campusWallIndexpath;
@property (nonatomic, readonly, strong) GLPPost *incomingPost;

@property (nonatomic, assign) viewCreator executeUrl;

-(id)initWithPost:(GLPPost*)post andImages:(NSMutableDictionary*)urls;
-(void)addPostImageUrl:(NSString*)url;


@end


@protocol PostUploaderDelegate <NSObject>

- (void)postUploaderDidFinish:(GLPPost *)uploadedPost;

@end