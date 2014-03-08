//
//  GLGroup.m
//  Gleepost
//
//  Created by Σιλουανός on 3/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPGroup.h"

@implementation GLPGroup

@synthesize remoteKey = _remoteKey;

-(id)initWithName:(NSString *)name andRemoteKey:(int)remoteKey
{
    self = [super init];
    
    if (self)
    {
        _name = name;
        _remoteKey = remoteKey;
    }
    
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Name: %@, Remote key: %d, Url: %@, Description: %@", _name, _remoteKey, _groupImageUrl, _groupDescription];
}

@end
