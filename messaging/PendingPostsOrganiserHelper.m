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
        if ([post pendingPostStatus] == kRejected)
        {
            [self addPost:post withHeader:self.firstHeader];
        }
        else
        {
            [self addPost:post withHeader:self.secondHeader];
        }
    }
}



@end
