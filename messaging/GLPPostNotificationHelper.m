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

+(int)parseLikedPostNotification:(NSNotification*)notification withPostsArray:(NSArray *)posts
{
    NSDictionary *dict = [notification userInfo];
    NSNumber *remoteKey = [dict objectForKey:@"RemoteKey"];
    NSNumber *liked = [dict objectForKey:@"Liked"];
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
    
    currentPost.liked = [liked boolValue];
    
    return index;
}

+(int)parsePost:(GLPPost **)post imageNotification:(NSNotification*)notification withPostsArray:(NSArray*)posts
{
    NSDictionary *dict = [notification userInfo];
    NSNumber *remoteKey = [dict objectForKey:@"RemoteKey"];
    UIImage *finalImage = [dict objectForKey:@"FinalImage"];
    
    GLPPost *currentPost = nil;
    
    int postIndex = [GLPPostNotificationHelper findPost:&currentPost with:[remoteKey intValue] fromPosts:posts];
    
    if(!currentPost)
    {
        post = nil;
        return postIndex;
    }
    else
    {
        currentPost.finalImage = finalImage;
        *post = currentPost;
    }
    
    return postIndex;
}

+(int)findPost:(GLPPost **)post with:(int)remoteKey fromPosts:(NSArray*)posts
{
    int i = 0;
    
    for(GLPPost* p in posts)
    {
        if(remoteKey == p.remoteKey)
        {
            *post = p;
            return i;
        }
        ++i;
    }
    
    return -1;
}

+(void)updatePostWithNotifiationName:(NSString*)notificationName withObject:(id)object remoteKey:(int)remoteKey numberOfLikes:(int)likes andNumberOfComments:(int)comments
{
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:remoteKey],@"RemoteKey", [NSNumber numberWithInt:comments], @"NumberOfComments",[NSNumber numberWithInt:likes], @"NumberOfLikes", nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:dataDict];
}

+(void)updatePostWithNotifiationName:(NSString*)notificationName withObject:(id)object remoteKey:(int)remoteKey withLiked:(BOOL)liked
{
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:remoteKey],@"RemoteKey", [NSNumber numberWithBool:liked], @"Liked", nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:dataDict];
}
@end
