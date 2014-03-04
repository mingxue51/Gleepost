//
//  GLPGroupManager.m
//  Gleepost
//
//  Created by Σιλουανός on 3/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPGroupManager.h"
#import "GLPGroup.h"
#import "WebClient.h"

@implementation GLPGroupManager

#pragma mark - Client methods

+ (void)loadInitialPostsWithGroupId:(int)groupId remoteCallback:(void (^)(BOOL success/*, BOOL remain*/, NSArray *remotePosts))remoteCallback
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
            remoteCallback(YES, posts);
        }
        else
        {
            remoteCallback(NO, nil);
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


#pragma mark - Processing methods

+(NSDictionary *)processGroups:(NSArray *)groups
{
    NSMutableArray *groupsStr = [[NSMutableArray alloc] init];
    
    NSArray *sections = [NSMutableArray arrayWithObjects: @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
    
    for (GLPGroup *group in groups)
    {
        [groupsStr addObject:group.name];
    }
    
    NSArray *finalSections = [self clearUselessSectionsWithSections:sections andGroups:groups];
    
    NSDictionary *categorisedGroups = [self categoriseByLetterWithSections:finalSections andGroups:groups];
    
    
    
    return [[NSDictionary alloc] initWithObjectsAndKeys:groupsStr, @"GroupNames", categorisedGroups, @"CategorisedGroups", finalSections, @"Sections" ,nil];
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


@end
