//
//  GLPPostNotificationHelper.m
//  Gleepost
//
//  Created by Σιλουανός on 27/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPostNotificationHelper.h"
#import "SessionManager.h"
#import "CampusWallGroupsPostsManager.h"
#import "AttendingPostsOrganiserHelper.h"

@implementation GLPPostNotificationHelper

+ (NSInteger)parseNotification:(NSNotification *)notification withPostsArray:(NSArray *)posts
{
    NSDictionary *dict = [notification userInfo];
    NSNumber *remoteKey = [dict objectForKey:@"RemoteKey"];
    NSNumber *numberOfComments = [dict objectForKey:@"NumberOfComments"];
    NSNumber *numberOfLikes = [dict objectForKey:@"NumberOfLikes"];
    
    NSInteger index = 0;
    
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
        return NSNotFound;
    }
    
    currentPost.commentsCount = [numberOfComments integerValue];
    currentPost.likes = [numberOfLikes integerValue];
    
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

/**
 Parse the image notification (that has been sent from GLPPostImageLoader), and returns (by reference) the updated post
 (with image) and YES (variable by reference as well) if the post already has image.
 
 @param post.
 @param notification and instance of an NSNotification class.
 @param containsImage.
 @param posts campus wall posts.
 
 @return the index of the post.
 
 */
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

+ (NSInteger)parsePostWithImageUrlNotification:(NSNotification *)notification withPostsArray:(NSArray *)posts
{
    NSDictionary *dict = [notification userInfo];
    
    NSInteger remoteKey = [(NSNumber*)[dict objectForKey:@"remoteKey"] integerValue];
    NSString *urlImage = [dict objectForKey:@"imageUrl"];
    
    GLPPost *currentPost = nil;
    
    int postIndex = [GLPPostNotificationHelper findPost:&currentPost with:remoteKey fromPosts:posts];
    
    
    if(!currentPost)
    {
        return postIndex;
    }
    
    if(urlImage)
    {
        currentPost.imagesUrls = [[NSArray alloc] initWithObjects:urlImage, nil];
    }
    
    return postIndex;
}

+ (NSInteger)parseRefreshCellNotification:(NSNotification *)notification withPostsArray:(NSArray *)posts
{
    NSDictionary *dict = [notification userInfo];
    NSNumber *remoteKey = [dict objectForKey:@"RemoteKey"];
    
    return [GLPPostNotificationHelper findPostIndexWithRemoteKey:remoteKey.integerValue inPosts:posts];
}

+(int)parseNotificationAndFindIndexWithNotification:(NSNotification *)notification withPostsArray:(NSMutableArray *)posts
{
    NSDictionary *dict = [notification userInfo];
    
    NSNumber *remoteKey = [dict objectForKey:@"RemoteKey"];
    
    GLPPost *post = [[GLPPost alloc] init];
    
    //Find the index of the post.
    int index = [GLPPostNotificationHelper findPost:&post with:[remoteKey integerValue] fromPosts:posts];
    
    if(index == -1)
    {
        return index;
    }
    
    DDLogDebug(@"Post Index %d", index);
    
    [self deletePostWithPost:post posts:posts andIndex:index];
    
    return index;
}

+(void)deletePostWithPost:(GLPPost *)post posts:(NSMutableArray *)posts andIndex:(int)index
{
//    if(post.group)
//    {
//        [[CampusWallGroupsPostsManager sharedInstance] removePostAtIndex:index];
//    }
//    else
//    {
        [posts removeObjectAtIndex:index];
//    }
}

+ (NSInteger)findPostIndexWithKey:(NSInteger)key inPosts:(NSArray *)posts
{
    NSInteger index = 0;
    
    for(GLPPost *p in posts)
    {
        if(p.key == key)
        {
            return index;
        }
        
        ++index;
    }
    
    return -1;
}

+ (NSInteger)findPostIndexWithRemoteKey:(NSInteger)remoteKey inPosts:(NSArray *)posts
{
    NSInteger index = 0;
    
//    [posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//       
//        GLPPost *currentPost = (GLPPost *)obj;
//        
//        if(currentPost.remoteKey == remoteKey)
//        {
//            index = idx;
//            *stop = YES;
//        }
//
//    }];
    
//    [posts enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//       
//        GLPPost *currentPost = (GLPPost *)obj;
//        
//        if(currentPost.remoteKey == remoteKey)
//        {
//            index = idx;
//            *stop = YES;
//        }
//
//    }];
//    
//    return index;
    
    for(GLPPost *p in posts)
    {
        if(p.remoteKey == remoteKey)
        {
            return index;
        }
        
        ++index;
    }
    
    return -1;
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

+(void)updatePostWithNotifiationName:(NSString*)notificationName withObject:(id)object remoteKey:(NSInteger)remoteKey numberOfLikes:(NSInteger)likes andNumberOfComments:(NSInteger)comments
{
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:remoteKey],@"RemoteKey", [NSNumber numberWithInt:comments], @"NumberOfComments",[NSNumber numberWithInteger:likes], @"NumberOfLikes", nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:dataDict];
}

+(void)updatePostWithNotifiationName:(NSString*)notificationName withObject:(id)object remoteKey:(int)remoteKey withLiked:(BOOL)liked
{
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:remoteKey],@"RemoteKey", [NSNumber numberWithBool:liked], @"Liked", nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:dataDict];
}

+ (void)deletePostNotificationWithPostRemoteKey:(NSInteger)remoteKey inCampusLive:(BOOL)postInCampusLive
{
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:remoteKey],@"RemoteKey", [NSNumber numberWithBool:postInCampusLive] , @"ComesFromCampusLive",nil];
    
    //TODO: See if the self object is good to set as a parameter.
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_POST_DELETED object:self userInfo:dataDict];
}

@end
