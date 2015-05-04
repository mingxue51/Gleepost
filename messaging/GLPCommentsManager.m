//
//  GLPCommentsManager.m
//  Gleepost
//
//  Created by Silouanos on 04/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Not a singlenton manager that should be intialised into the view controller that wants to
//  have operations have to do with comments about only one post.

#import "GLPCommentsManager.h"
#import "GLPCommentManager.h"

@class GLPPost;

@interface GLPCommentsManager ()

@property (assign, nonatomic) GLPPost *post;
@property (strong, nonatomic) NSArray *comments;

@end

@implementation GLPCommentsManager

- (instancetype)initWithPost:(GLPPost *)post
{
    self = [super init];
    
    if (self)
    {
        self.post = post;
        
        [self loadComments];
    }
    return self;
}

#pragma mark - Operations

- (void)loadComments
{
    [GLPCommentManager loadCommentsWithPost:self.post localCallback:^(NSArray *localComments) {
        
        self.comments = localComments;
        
    } remoteCallback:^(BOOL success, NSArray *remoteComments){
        
        if(success)
        {
            self.comments = remoteComments;
            [self notifyPostWithComments];
        }
        
    }];
}

#pragma mark - Accessors

- (void)getComments
{
    
}

- (GLPComment *)commentAtIndex:(NSInteger)index
{
    return [self.comments objectAtIndex:index];
}

- (NSInteger)commentsCount
{
    return self.comments.count;
}

#pragma mark - Notifications

- (void)notifyPostWithComments
{
    //GLPNOTIFICATION_COMMENTS_FETCHED
}

@end
