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
@synthesize key = _key;
@synthesize isFromPushNotification = _isFromPushNotification;

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

- (id)initFromPushNotificationWithRemoteKey:(NSInteger)remoteKey
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.remoteKey = remoteKey;
    _isFromPushNotification = YES;
//    _title = @"Loading conversation";
    
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Name: %@, Key: %d, Remote key: %d, Url: %@, Description: %@", _name, _key, _remoteKey, _groupImageUrl, _groupDescription];
}

@end
