//
//  GLPCommentsManager.m
//  Gleepost
//
//  Created by Silouanos on 04/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Not a singlenton manager that should be intialised into the campus live view controller
//  have operations have to do with comments. It holds all the latest comments of all the campus live posts
//  for efficiency purposes.

#import "CLCommentsManager.h"
#import "GLPCommentManager.h"
#import "GLPiOSSupportHelper.h"
#import "GLPCLCommentsOperation.h"
#import "CommentCell.h"

@class GLPPost;

@interface CLCommentsManager () <GLPCLCommentsOperationDelegate>

@property (strong, nonatomic) NSOperationQueue *operationQueue;

/** <post, comments array> */
@property (strong, nonatomic) NSMutableDictionary *postComments;

@property (strong, nonatomic) GLPPost *selectedPost;

@end

@implementation CLCommentsManager

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self initialiseObjects];
    }
    return self;
}

#pragma mark - Configuration

- (void)initialiseObjects
{
    self.postComments = [[NSMutableDictionary alloc] init];
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    if(![GLPiOSSupportHelper isIOS7])
    {
        _operationQueue.qualityOfService =  NSQualityOfServiceUtility;
    }
}

#pragma mark - Operations

- (void)startLoadCommentsOperationWithPost:(GLPPost *)post
{
    GLPCLCommentsOperation *commentsOperation = [[GLPCLCommentsOperation alloc] initWithPost:post];
    commentsOperation.delegate = self;
    [self.operationQueue addOperation:commentsOperation];
}

#pragma mark - Accessors

/**
 If there are already comments in memory (in our datastructure) send nsnotification
 with the current ones. If not don't do anything. After that start the operation
 that will load (and send nsnotification if there are some) the local comments.
 Finally load from server and send an update again.
 
 @param post the selected post.
 
 */
- (void)loadCommentsWithPost:(GLPPost *)post
{
    self.selectedPost = post;

    NSArray *comments = self.postComments[@(post.remoteKey)];
    
    if(comments)
    {
        [self notifyWithPostsComments:post];
    }
    
    //Start operation.
    [self startLoadCommentsOperationWithPost:post];
}

- (GLPComment *)commentAtIndex:(NSInteger)index withPost:(GLPPost *)post
{
    NSArray *comments = self.postComments[@(post.remoteKey)];
    
    return [comments objectAtIndex:index];
}

- (NSInteger)commentsCountWithPost:(GLPPost *)post
{
    NSArray *comments = self.postComments[@(post.remoteKey)];
    return comments.count;
}


/**
 Calculates and returns the height of all the comment cells.
 
 @param post The selected post.
 
 */
- (CGFloat)commentCellsHeightWithPost:(GLPPost *)post
{
    NSArray *comments = self.postComments[@(post.remoteKey)];
    
    CGFloat totalHeight = 0.0;
    
    for(GLPComment *comment in comments)
    {
        totalHeight += [CommentCell getCellHeightWithContent:comment.content image:NO];
    }
    
    return totalHeight;
}

#pragma mark - GLPCLCommentsOpeation

- (void)comments:(NSArray *)comments forPost:(GLPPost *)post
{
    [self.postComments setObject:comments forKey:@(post.remoteKey)];

    if(post.remoteKey == self.selectedPost.remoteKey)
    {
        [self notifyWithPostsComments:post];
    }
}

#pragma mark - Notifications

- (void)notifyWithPostsComments:(GLPPost *)post
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_COMMENTS_FETCHED object:self userInfo:@{@"post" : post}];
}

@end
