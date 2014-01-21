//
//  GLPCategory.m
//  Gleepost
//
//  Created by Silouanos on 21/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCategory.h"

@implementation GLPCategory

@synthesize tag = _tag;
@synthesize name = _name;
@synthesize postRemoteKey = _postRemoteKey;

-(id)initWithTag:(NSString*)tag name:(NSString*)name andPostRemoteKey:(int)postRemoteKey
{
    self = [super init];
    
    if(self)
    {
//        self.remoteKey = remoteKey;
        _tag = tag;
        _name = name;
        _postRemoteKey = postRemoteKey;
    }
    
    return self;
}

-(id)initWithTag:(NSString*)tag name:(NSString*)name postRemoteKey:(int)postRemoteKey andRemoteKey:(int)remoteKey
{
    self = [super init];
    
    if(self)
    {
        self.remoteKey = remoteKey;
        _tag = tag;
        _name = name;
        _postRemoteKey = postRemoteKey;
    }
    
    return self;
}


-(NSString*)description
{
    return [NSString stringWithFormat:@"Remote Key: %d, Tag: %@, Name: %@, Post Remote Key: %d",self.remoteKey, _tag, _name, _postRemoteKey];
}


@end
