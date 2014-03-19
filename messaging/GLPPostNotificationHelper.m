//
//  GLPPostNotificationHelper.m
//  Gleepost
//
//  Created by Σιλουανός on 27/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPostNotificationHelper.h"
#import "SessionManager.h"

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

/**
 Parse notification after the change of user's profile image in order to find user's posts to refresh them.
 
 @param notification.
 @param posts array of the posts of the campus wall.
 @param profileImageUrl the new profile image url.
 
 @return an array with all the posts' indexes that need to refresh.
 
 */
+(NSArray *)parseNotification:(NSNotification *)notification withPostsArrayForNewProfileImage:(NSArray *)posts
{
    NSMutableArray *postsIndexes = [[NSMutableArray alloc] init];
    
    NSDictionary *dict = [notification userInfo];
    
    NSString *profileUrl = [dict objectForKey:@"profile_image_url"];
    
    int userRemoteKey = [SessionManager sharedInstance].user.remoteKey;
    
    //Find all the current user's posts.
    for(int i = 0; i < posts.count; ++i)
    {
        GLPPost *currentPost = posts[i];
        
        if(currentPost.author.remoteKey == userRemoteKey)
        {
            currentPost.author.profileImageUrl = profileUrl;
            
            [postsIndexes addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return postsIndexes;
    
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

+(int)parseNotificationAndFindIndexWithNotification:(NSNotification *)notification withPostsArray:(NSMutableArray *)posts
{
    NSDictionary *dict = [notification userInfo];
    
    NSNumber *remoteKey = [dict objectForKey:@"RemoteKey"];
    
    
    for(GLPPost *postC in posts)
    {
        if(postC.remoteKey == [remoteKey integerValue])
        {
            DDLogDebug(@"FOUND! Remote Key: %d, Content: %@", postC.remoteKey, postC.content);
        }
    }
    

    
    GLPPost *post = [[GLPPost alloc] init];
    
    //Find the index of the post.
    int index = [GLPPostNotificationHelper findPost:&post with:[remoteKey integerValue] fromPosts:posts];
    
    if(index == -1)
    {
        return index;
    }
    
    [posts removeObjectAtIndex:index];

    
    DDLogDebug(@"Post to be deleted: %@", post);
    
    return index;
    
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

+(void)deletePostNotificationWithPostRemoteKey:(int)remoteKey
{
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:remoteKey],@"RemoteKey", nil];
    
    //TODO: See if the self object is good to set as a parameter.
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_POST_DELETED object:self userInfo:dataDict];
}

@end
