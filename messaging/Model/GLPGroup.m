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
        _unreadNewPosts = 0;
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
    _unreadNewPosts = 0;
//    _title = @"Loading conversation";
    
    return self;
}

- (NSString *)privacyToString
{
    switch (_privacy) {
        case kSecretGroup:
            return @"secret";
            break;
            
        case kPrivateGroup:
            return @"private";
            break;
            
        case kPublicGroup:
            return @"public";
            break;

        default:
            return nil;
            break;
    }
}

- (void)setPrivacyWithString:(NSString *)privacy
{
    if([privacy isEqualToString:@"secret"])
    {
        _privacy = kSecretGroup;
    }
    else if ([privacy isEqualToString:@"private"])
    {
        _privacy = kPrivateGroup;
    }
    else
    {
        _privacy = kPublicGroup;
    }
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Name: %@, Key: %d, Remote key: %d, Url: %@, Description: %@, Privacy: %@", _name, _key, _remoteKey, _groupImageUrl, _groupDescription, [self privacyToString]];
}

@end
