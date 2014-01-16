//
//  GLPPostNotificationHelper.m
//  Gleepost
//
//  Created by Σιλουανός on 27/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPostNotificationHelper.h"

@implementation GLPPostNotificationHelper

+(int)parseNotification:(NSNotification*)notification withPostsArray:(NSArray*)posts
{
    NSDictionary *dict = [notification userInfo];
    NSNumber *remoteKey = [dict objectForKey:@"RemoteKey"];
    NSNumber *numberOfComments = [dict objectForKey:@"NumberOfComments"];
    NSNumber *numberOfLikes = [dict objectForKey:@"NumberOfLikes"];
    
    int index = 0;
    
    GLPPost *currentPost = nil;
    
    //Find post by remote key.
    for(GLPPost *p in posts)
    {
        if([remoteKey intValue] == p.remoteKey)
        {
            
            currentPost = p;
            
            break;
        }
        ++index;
    }
    
    if(currentPost == nil)
    {
        return -1;
    }
    
    currentPost.commentsCount = [numberOfComments intValue];
    currentPost.likes = [numberOfLikes intValue];
    
    return index;
}

+(GLPPost*)parsePostImageNotification:(NSNotification*)notification withPostsArray:(NSArray*)posts
{
    NSDictionary *dict = [notification userInfo];
    NSNumber *remoteKey = [dict objectForKey:@"RemoteKey"];
    UIImage *finalImage = [dict objectForKey:@"FinalImage"];
    
    GLPPost *currentPost = [GLPPostNotificationHelper findPostWith:[remoteKey intValue] fromPosts:posts];
    
    if(!currentPost)
    {
        return nil;
    }
    else
    {
        currentPost.finalImage = finalImage;
    }
    
    return currentPost;
}

+(GLPPost*)findPostWith:(int)remoteKey fromPosts:(NSArray*)posts
{
    for(GLPPost* p in posts)
    {
        if(remoteKey == p.remoteKey)
        {
            return p;
        }
    }
    
    return nil;
}

+(void)updatePostWithNotifiationName:(NSString*)notificationName withObject:(id)object remoteKey:(int)remoteKey numberOfLikes:(int)likes andNumberOfComments:(int)comments
{
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:remoteKey],@"RemoteKey", [NSNumber numberWithInt:comments], @"NumberOfComments",[NSNumber numberWithInt:likes], @"NumberOfLikes", nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:dataDict];
}


@end
