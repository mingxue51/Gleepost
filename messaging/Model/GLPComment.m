//
//  GLPComment.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPComment.h"

@implementation GLPComment

-(id)init
{
    self = [super init];
    
    if(self)
    {
        _sendStatus = kSendStatusLocal;
    }
    
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Remote key: %d, Post remote key: %d, Post key: %d, Content: %@, Date: %@ Send status: %d", self.remoteKey, self.post.remoteKey, self.post.key ,self.content, self.date, self.sendStatus];
}

@end
