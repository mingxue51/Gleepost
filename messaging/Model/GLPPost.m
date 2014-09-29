//
//  GLPPost.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPost.h"
#import "GLPVideo.h"

@implementation GLPPost

@synthesize likes;
@synthesize dislikes;
@synthesize commentsCount;
@synthesize content;
@synthesize date;
@synthesize author;
@synthesize imagesUrls;
@synthesize sendStatus=_sendStatus; 
//@synthesize liked=_liked;

- (id)init
{
    self = [super init];
    if(!self) {
        return self;
    }
    
    _sendStatus = kSendStatusLocal;
    //_liked = NO;
    
    return self;
}

- (id)initWithRemoteKey:(NSInteger)remoteKey
{
    self = [super init];
    
    if(self)
    {
        self.remoteKey = remoteKey;
    }
    
    return self;
}

-(BOOL)imagePost
{
    if (imagesUrls == nil || [imagesUrls count] == 0)
    {
        return NO;
    }
    
    DDLogDebug(@"");
    
    return YES;
}

-(BOOL)isVideoPost
{
    if(_video == nil)
    {
        return NO;
    }
    
    return YES;
}

-(BOOL)isGroupPost
{
    if(_group != nil)
    {
        return YES;
    }
    
    return NO;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Post id: %ld, Content: %@ Sending status: %d Date: %@, Group: %@ ", (long)self.remoteKey, self.content, self.sendStatus, self.date, self.group];
}



@end
