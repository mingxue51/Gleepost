//
//  GLPPost.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPost.h"

@implementation GLPPost

@synthesize likes;
@synthesize dislikes;
@synthesize commentsCount;
@synthesize content;
@synthesize date;
@synthesize author;
@synthesize imagesUrls;
@synthesize sendStatus=_sendStatus;

- (id)init
{
    self = [super init];
    if(!self) {
        return self;
    }
    
    _sendStatus = kSendStatusLocal;
    
    return self;
}

-(BOOL) imagePost
{
    if (imagesUrls == nil || [imagesUrls count] == 0)
    {
        return NO;
    }
    
    return YES;
}



@end
