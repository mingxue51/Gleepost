//
//  GLPCommentUploader.m
//  Gleepost
//
//  Created by Silouanos on 25/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCommentUploader.h"
#import "SessionManager.h"
#import "GLPCommentDao.h"
#import "GLPPostOperationManager.h"

@implementation GLPCommentUploader

-(GLPComment *)uploadCommentWithContent:(NSString *)content andPost:(GLPPost *)post
{
    GLPComment *comment = [self createCommentWithConent:content andPost:post];
    
    //Save comment locally.
    [GLPCommentDao save:comment];
    
    //Set comment to uploader. (update once is uploaded)
    [[GLPPostOperationManager sharedInstance] uploadComment:comment];
    
    return comment;
}

-(GLPComment *)createCommentWithConent:(NSString *)content andPost:(GLPPost *)post
{
    GLPComment *comment = [[GLPComment alloc] init];
    comment.content = content;
    comment.post = post;
    comment.author = [SessionManager sharedInstance].user;
    comment.date = [NSDate date];
    comment.sendStatus = kSendStatusLocal;
    
    return comment;
}

-(NSArray *)pendingCommentsWithPostKey:(int)postKey
{
    NSArray *pendingComments = [[GLPPostOperationManager sharedInstance] getCommentsWithPostKey:postKey];
    
    if(pendingComments)
    {
        return pendingComments;
    }
    
    return [[NSArray alloc] init];
}


@end
