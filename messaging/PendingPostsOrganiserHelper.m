//
//  PendingPostsOrganiserHelper.m
//  Gleepost
//
//  Created by Silouanos on 26/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "PendingPostsOrganiserHelper.h"

@implementation PendingPostsOrganiserHelper

- (id)init
{
    self = [super initWithFirstHeader:@"Rejected Posts" andSecondHeader:@"Pending Posts"];
    
    if(self)
    {
        
    }
    
    return self;
}

/**
 This method organise the posts in the following stucture:
 
 NSArray {NSDictionary (Header, NSArray<GLPPost>), ...}
 
 @param posts an array of posts.
 
 */
- (void)organisePosts:(NSArray *)posts
{
    for(GLPPost *post in posts)
    {
        
        DDLogDebug(@"Content %@, Pending status %d", post.content, [post pendingPostStatus]);
        
        if ([post pendingPostStatus] == kRejected)
        {
            [self addPost:post withHeader:self.firstHeader];
            
            if ([post.content isEqualToString:@"I'm so"])
            {
                DDLogDebug(@"Rejected I AM SO %@", post.reviewHistory);
            }
        }
        else
        {
            [self addPost:post withHeader:self.secondHeader];
            
            if ([post.content isEqualToString:@"I'm so "])
            {
                DDLogDebug(@"Pending I AM SO %@", post.reviewHistory);
            }
        }
    }
    
    [self fixPositionsHeadersInSectionArrayIfNeeded];
}

- (void)fixPositionsHeadersInSectionArrayIfNeeded
{
    NSDictionary *d = self.sections[0];
    
    if(![d objectForKey:self.firstHeader])
    {
        NSDictionary *d1 = self.sections[0];
        
        self.sections[0] = self.sections[1];
        self.sections[1] = d1;
    }
    
}

- (NSIndexPath *)addImageUrl:(NSString *)imageUrl toPostWithRemoteKey:(NSInteger)postRemoteKey
{
    NSInteger row = 0;
    NSInteger section = 0;
    
    for(NSDictionary *sectionDict in self.sections)
    {
        NSArray *postsSection = [sectionDict objectForKey:[[sectionDict allKeys] objectAtIndex:0]];
        
        for(GLPPost *p in postsSection)
        {
            if(p.remoteKey == postRemoteKey)
            {
                p.imagesUrls = [[NSArray alloc] initWithObjects:imageUrl, nil];
                return [NSIndexPath indexPathForItem:row inSection:section];
            }
            ++row;
        }
        row = 0;
        
        ++section;
    }
    
    return nil;
}




@end
