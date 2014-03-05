//
//  CampusWallGroupsPostsManager.m
//  Gleepost
//
//  Created by Σιλουανός on 4/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CampusWallGroupsPostsManager.h"

@interface CampusWallGroupsPostsManager ()

@property (strong, nonatomic) NSMutableArray *posts;

@end

@implementation CampusWallGroupsPostsManager


static CampusWallGroupsPostsManager *instance = nil;

+(CampusWallGroupsPostsManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[CampusWallGroupsPostsManager alloc] init];
    });
    
    return instance;
}

#pragma mark - Initilisation

-(id)init
{
    self = [super init];
    
    if(self)
    {
        [self initialiseObjects];
    }
    
    return self;
}


-(void)initialiseObjects
{
    _posts = [[NSMutableArray alloc] init];
}

#pragma mark -

#pragma mark - Modifiers

-(void)setPosts:(NSMutableArray *)posts
{
    _posts = posts;
}

#pragma mark - Accessors

-(GLPPost *)postAtIndex:(int)index
{
    return [_posts objectAtIndex:index];
}

-(NSArray *)allPosts
{
    return _posts;
}

-(BOOL)arePostsEmpty
{
    return (_posts.count == 0);
}

@end
