//
//  GLPGroupManager.m
//  Gleepost
//
//  Created by Σιλουανός on 3/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPGroupManager.h"
#import "WebClient.h"
#import "GLPGroupDao.h"
#import "DatabaseManager.h"

@implementation GLPGroupManager


#pragma mark - Groups methods

+ (void)loadGroups:(NSArray *)groups withLocalCallback:(void (^)(NSArray *groups))localCallback remoteCallback:(void (^)(BOOL success, NSArray *groups))remoteCallback
{
    
    //Find all the groups that contain real images and save them.
    
    NSMutableArray *pendingGroups = [[self findGroupsWithRealImagesWithGroups:groups] mutableCopy];
    
    NSMutableArray *localEntities = [[GLPGroupDao findRemoteGroups] mutableCopy];
    
//    localEntities = [self overwriteGroups:localEntities withImagesGroups:localGroupsWithImages];
    
    [localEntities addObjectsFromArray:pendingGroups];
    
    localCallback(localEntities);
    
    
    [[WebClient sharedInstance ] getGroupswithCallbackBlock:^(BOOL success, NSArray *serverGroups) {
        
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        
        
        //Store only groups that are not exist into the database.

        [GLPGroupDao saveGroups:serverGroups];
        
//        NSArray *finalRemoteGroups = [self overwriteGroups:serverGroups withImagesGroups:localGroupsWithImages];
        
        NSMutableArray *finalRemoteGroups = [serverGroups mutableCopy];
        
//        [GLPGroupManager removePendingGroupsIfExist:pendingGroups withRemoteGroups:finalRemoteGroups];
        
        [finalRemoteGroups addObjectsFromArray:pendingGroups];
        
        remoteCallback(YES, finalRemoteGroups);

     
//        remoteCallback(YES, [GLPGroupManager addLocalGroups:localEntities toRemoteGroups:serverGroups]);
     
      }];
}

//+(NSArray *)removePendingGroupsIfExist:(NSArray *)pending withRemoteGroups:(NSArray *)remoteGroups
//{
//    
//}

+ (NSArray *)addLocalGroups:(NSArray *)localGroups toRemoteGroups:(NSArray *)remoteGroups
{
    NSMutableArray *finalGroups = remoteGroups.mutableCopy;
    
    for(GLPComment *localGroup in localGroups)
    {
        if(localGroup.remoteKey == 0)
        {
            [finalGroups setObject:localGroup atIndexedSubscript:0];
        }
    }
    
    return finalGroups;
}


+(NSArray *)findGroupsWithRealImagesWithGroups:(NSArray *)groups
{
    NSMutableArray *finalGroups = [[NSMutableArray alloc] init];
    
    for(GLPGroup *group in groups)
    {
        if(group.finalImage)
        {
            [finalGroups addObject:group];
        }
    }
    
    return finalGroups;
}


//TODO: Inefficient code.

/**
 
 Overwrites all the posts that are not having real image with posts that exist in the app and have real images.
 
 */
+(NSArray *)overwriteGroups:(NSArray *)groups withImagesGroups:(NSArray *)groupsImages
{
    NSMutableArray *finalGroups = groups.mutableCopy;

    BOOL sameKey = NO;
    
    for(int i = 0; i<groups.count; ++i)
    {
//        int gKey =

        GLPGroup *currentGroup = [groups objectAtIndex:i];
        
        for(int j = 0; j<groupsImages.count; ++j)
        {
//            int gImageKey = [[groupsImages objectAtIndex:j] remoteKey];
            
            GLPGroup *groupImage = [groupsImages objectAtIndex:j];

            
            if(groupImage.remoteKey == currentGroup.remoteKey)
            {
                
                if(currentGroup.sendStatus == kSendStatusSent)
                {
                    groupImage = currentGroup;
                }
                else
                {
                    [finalGroups replaceObjectAtIndex:i withObject:groupImage];
                }
                
                sameKey = YES;
            }
        }
    }
    
    if(!sameKey && groupsImages.count > 0)
    {
        [finalGroups addObjectsFromArray:groupsImages];
    }
    
    return finalGroups;
}


+ (void)deleteGroup:(GLPGroup *)group
{
    [GLPGroupDao remove:group];
}

#pragma mark - Posts methods

+ (void)loadInitialPostsWithGroupId:(int)groupId remoteCallback:(void (^)(BOOL success, BOOL remain, NSArray *remotePosts))remoteCallback
{
    NSLog(@"load initial group posts with id: %d", groupId);
    
//    __block NSArray *localEntities = nil;
//    [DatabaseManager run:^(FMDatabase *db) {
//        localEntities = [GLPPostDao findLastPostsInDb:db];
//    }];
//    
//    NSLog(@"local posts %d", localEntities.count);
//    
//    if(localEntities.count > 0) {
//        localCallback(localEntities);
//    }
    
    [[WebClient sharedInstance] getPostsAfter:nil withGroupId:groupId callback:^(BOOL success, NSArray *posts) {
       
        if(success)
        {
            BOOL remains = posts.count == kGLPNumberOfPosts ? YES : NO;

            
            remoteCallback(YES, remains, posts);
        }
        else
        {
            remoteCallback(NO, NO, nil);
            return;
        }
        
    }];
    
    
//    [[WebClient sharedInstance] getPostsAfter:nil withCategoryTag:[SessionManager sharedInstance].currentCategory.tag callback:^(BOOL success, NSArray *posts) {
//        if(!success) {
//            remoteCallback(NO, NO, nil);
//            return;
//        }
//        
//        NSLog(@"remote posts %d", posts.count);
//        
//        if(!posts || posts.count == 0) {
//            remoteCallback(YES, NO, nil);
//            return;
//        }
//        
//        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//            
//            // get list of posts with liked=YES
//            //            NSArray* likedPosts = [GLPPostDao likedPostsInDb:db];
//            
//            // clean posts table
//            [GLPPostDao deleteAllInDb:db];
//            
//            //Set liked to the database if the user liked from other device (?)
//            for(GLPPost *post in posts)
//            {
//                [GLPPostDao save:post inDb:db];
//            }
//        }];
//        
//        BOOL remains = posts.count == kGLPNumberOfPosts ? YES : NO;
//        
//        remoteCallback(YES, remains, posts);
//    }];
}


+ (void)loadRemotePostsBefore:(GLPPost *)post withGroupRemoteKey:(int)remoteKey callback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback
{
    NSLog(@"load posts before %d - %@", post.remoteKey, post.content);
    
    [[WebClient sharedInstance] getPostsAfter:nil withGroupId:remoteKey callback:^(BOOL success, NSArray *posts) {
       
        if(!success) {
            callback(NO, NO, nil);
            return;
        }
        
        
        // take only new posts
        NSMutableArray *newPosts = [NSMutableArray array];
        for (GLPPost *newPost in posts) {
            
            if(newPost.remoteKey == post.remoteKey) {
                break;
            }
            
//            if([GLPPostManager isPost:newPost containedInArray:notUploadedPosts])
//            {
//                continue;
//            }
            
            //If newPost is contained to already posted posts then continue.
            //Avoid duplications.
            //            if([GLPPostManager isPost:newPost containedInArray:posts])
            //            {
            //                continue;
            //            }
            
            
            
            [newPosts addObject:newPost];
        }
        
        //[newPosts addObject:post]; //[newPosts addObject:post]; [newPosts addObject:post]; // comment / uncomment for debug reasons
        
        NSLog(@"remote posts %d", newPosts.count);
        
        if(!newPosts || newPosts.count == 0) {
            callback(YES, NO, nil);
            return;
        }
        
        // only new posts loaded, means it may remain some
        BOOL remain = newPosts.count == posts.count;
        
//        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//            for (GLPPost *newPost in newPosts) {
//                [GLPPostDao save:newPost inDb:db];
//            }
//        }];
        
        callback(YES, remain, newPosts);
        
    }];
}

+ (void)loadPreviousPostsAfter:(GLPPost *)post withGroupRemoteKey:(int)remoteKey callback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback
{
    NSLog(@"load posts after %d - %@", post.remoteKey, post.content);
    
//    __block NSArray *localEntities = nil;
//    [DatabaseManager run:^(FMDatabase *db) {
//        localEntities = post ? [GLPPostDao findLastPostsAfter:post inDb:db] : [GLPPostDao findLastPostsInDb:db];
//    }];
    
//    NSLog(@"local posts %d", localEntities.count);
    
//    if(localEntities.count > 0) {
//        // delay for infime ms because fuck ios development
//        double delayInSeconds = 0.1;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            callback(YES, YES, localEntities);
//        });
//        
//        return;
//    }
    
    [[WebClient sharedInstance] getPostsAfter:post withGroupId:remoteKey callback:^(BOOL success, NSArray *posts) {
       
        if(!success) {
            callback(NO, NO, nil);
            return;
        }
        
        
        NSLog(@"remote posts %d", posts.count);
        
        if(!posts || posts.count == 0) {
            callback(YES, NO, nil);
            return;
        }
        
//        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//            for(GLPPost *post in posts) {
//                [GLPPostDao save:post inDb:db];
//            }
//        }];
        
        BOOL remains = posts.count == kGLPNumberOfPosts ? YES : NO;
        
        callback(YES, remains, posts);
    }];
}

+(void)loadGroupsFeedWithCallback:(void (^) (BOOL success, NSArray *posts))callback
{
    [[WebClient sharedInstance] getPostsGroupsFeedWithCallbackBlock:^(BOOL success, NSArray *posts) {
       
        if(success)
        {
            DDLogDebug(@"Feed posts: %@", posts);
            
            callback(YES, posts);
            
        }
        else
        {
            DDLogError(@"Groups' posts feed not able to load");
            
            callback(NO, nil);
        }
        
        
    }];
}

#pragma mark - Processing methods

+(NSDictionary *)processGroups:(NSArray *)groups
{
    NSMutableArray *groupsStr = [[NSMutableArray alloc] init];
    
//    NSArray *sections = [NSMutableArray arrayWithObjects: @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
    
    for (GLPGroup *group in groups)
    {
        [groupsStr addObject:group.name];
    }
    
    
    NSArray *finalSections = [self findValidSections:groups];
    
    NSDictionary *categorisedGroups = [self categoriseByLetterWithSections:finalSections andGroups:groups];
    
    
    
    return [[NSDictionary alloc] initWithObjectsAndKeys:groupsStr, @"GroupNames", categorisedGroups, @"CategorisedGroups", finalSections, @"Sections" ,nil];
}

+(NSArray *)findValidSections:(NSArray *)groups
{
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    
    for(GLPGroup* group in groups)
    {
        NSString* groupName = group.name;
        //Get the first letter of the user.
        NSString* firstLetter = [groupName substringWithRange: NSMakeRange(0, 1)];
        
        firstLetter = [firstLetter uppercaseString];
        
        [sections addObject:firstLetter];
        
    }
    
    
    
    sections = [sections valueForKeyPath:@"@distinctUnionOfObjects.self"];
    
    sections = [sections sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)].mutableCopy;


    
    return sections;
}

+(NSArray *)clearUselessSectionsWithSections:(NSArray *)sections andGroups:(NSArray *)groups
{
    BOOL sectionFound = NO;
    NSMutableArray *deletedSections = [[NSMutableArray alloc] init];
    NSMutableArray *finalSections = sections.mutableCopy;
    
    for(NSString* letter in sections)
    {
        for(GLPGroup* group in groups)
        {
            NSString* userName = group.name;
            //Get the first letter of the user.
            NSString* firstLetter = [userName substringWithRange: NSMakeRange(0, 1)];
            
            if([firstLetter caseInsensitiveCompare:letter] == NSOrderedSame)
            {
                sectionFound = YES;
            }
        }
        
        //Delete a section if it is not necessary.
        if(!sectionFound)
        {
            [deletedSections addObject:letter];
        }
        else
        {
            sectionFound = NO;
        }
    }
    
    //Remove sections.
    for(NSString* letter in deletedSections)
    {
        [finalSections removeObject:letter];
    }
    
    return finalSections;
}

+(NSDictionary *)categoriseByLetterWithSections:(NSArray *)sections andGroups:(NSArray *)groups
{
    int indexOfLetter = 0;
    BOOL sectionFound = NO;
    NSMutableArray *deletedSections = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *categorisedGroups = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *finalSections = sections.mutableCopy;
    
    //NSNumber* indexOfLetter = [[NSNumber alloc] initWithInt:0];
    
    for(NSString* letter in sections)
    {
        for(GLPGroup* group in groups)
        {
            NSString* name = group.name;
            
            //Get the first letter of the user.
            NSString* firstLetter = [name substringWithRange: NSMakeRange(0, 1)];
            
            if([firstLetter caseInsensitiveCompare:letter] == NSOrderedSame)
            {
                sectionFound = YES;
                
                //Check if the dictonary has previous elements in the current key.
                NSMutableArray *currentUsers = [categorisedGroups objectForKey:[NSNumber numberWithInt:indexOfLetter]];
                
                if(currentUsers == nil)
                {
                    currentUsers = [[NSMutableArray alloc] init];
                    [currentUsers addObject:group];
                }
                else
                {
                    //Add the user to the existing section.
                    [currentUsers addObject:group];
                }
                
                [categorisedGroups setObject:currentUsers forKey:[NSNumber numberWithInt:indexOfLetter]];
                
            }
        }
        
        //Delete a section if it is not necessary.
        if(!sectionFound)
        {
            [deletedSections addObject:letter];
        }
        else
        {
            sectionFound = NO;
        }
        
        ++indexOfLetter;
    }
    
    //Remove sections.
    for(NSString* letter in deletedSections)
    {
        [finalSections removeObject:letter];
    }
    
    return categorisedGroups;
}

/**
 Finds the row and section number of the current group with remote key.
 
 @param remoteKey group remote key.
 @param dictionary the categorised dictionary that contains all groups in section order.
 
 @return the index path of the group.
 
 */

+(NSIndexPath *)findIndexPathForGroupRemoteKey:(int)remoteKey withCategorisedGroups:(NSMutableDictionary *)dictionary
{
    int row = 0;
    
    for(NSNumber *index in dictionary)
    {
        NSArray *groups = [dictionary objectForKey:index];
                
        for(GLPGroup *g in groups)
        {
            if(g.remoteKey == remoteKey)
            {
                return [NSIndexPath indexPathForRow:row inSection:[index integerValue]];
            }
            ++row;
        }
        row = 0;
    }
    
    return nil;
}

#pragma mark - Notifications methods

+(int)parseNotification:(NSNotification*)notification withGroupsArray:(NSArray*)groups
{
    NSDictionary *dict = [notification userInfo];
    NSNumber *remoteKey = [dict objectForKey:@"remoteKey"];
    NSNumber *key = [dict objectForKey:@"key"];
    NSString *imageUrl = [dict objectForKey:@"imageUrl"];

    
    int index = 0;
    
    GLPGroup *currentGroup = nil;
    
    //Find post by remote key.
    for(GLPGroup *g in groups)
    {
        if([key intValue] == g.key)
        {
            currentGroup = g;
            currentGroup.finalImage = nil;
            
            break;
        }
        ++index;
    }
    
    if(currentGroup == nil)
    {
        return -1;
    }
    
    currentGroup.remoteKey = [remoteKey intValue];
    currentGroup.groupImageUrl = imageUrl;
    
    return [remoteKey integerValue];
}



@end
