//
//  GLPCommentManager.m
//  Gleepost
//
//  Created by Silouanos on 25/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCommentManager.h"
#import "WebClient.h"


@implementation GLPCommentManager

+ (void)loadCommentsWithLocalCallback:(void (^)(NSArray *comments))localCallback remoteCallback:(void (^)(BOOL success, NSArray *comments))remoteCallback withPost:(GLPPost *)post
{
    //Load local comments.
    NSArray *localComments = [GLPCommentDao findCommentsByPostRemoteKey:post.remoteKey];
    
    localCallback(localComments);
    
    
    //Load remote comments.
    [[WebClient sharedInstance] getCommentsForPost:post withCallbackBlock:^(BOOL success, NSArray *comments) {
        
        if(success) {
            
            //Save new comments in database.
            [GLPCommentManager saveCommentsInDb:comments];
            
           
            //If there are comments in db and not in server show them.
            remoteCallback(success, [self addLocalComments:localComments toRemoteComments:comments]);
            
        } else {
//            [WebClientHelper showStandardError];
            remoteCallback(success, nil);
        }
    }];
}

//+ (void)loadLocalCommentsWithPost:(GLPPost *)post andLocalCallback:(void (^)(NSArray *comments))localCallback
//{
//    
//}


+ (void)saveCommentsInDb:(NSArray *)comments
{
    for(GLPComment *comment in comments)
    {
        comment.sendStatus = kSendStatusSent;
        [GLPCommentDao saveIfNotExist:comment];
    }
}

+ (NSArray *)addLocalComments:(NSArray *)localComments toRemoteComments:(NSArray *)remoteComments
{
    NSMutableArray *finalComments = remoteComments.mutableCopy;
    
    for(GLPComment *localComment in localComments)
    {
        if(localComment.remoteKey == 0)
        {
            [finalComments insertObject:localComment atIndex:0];
        }
    }
    
    return finalComments;
}

@end
