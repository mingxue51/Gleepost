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

-(id)initWithName:(NSString *)name andRemoteKey:(NSInteger)remoteKey
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

- (NSString *)generatePendingIdentifier
{
    return [NSString stringWithFormat:@"PENDING_%ld", (long)self.key];
}

- (BOOL)isEqual:(id)other
{
    GLPGroup *otherGroup = (GLPGroup *)other;
    
    if(self.remoteKey == 0 || otherGroup.remoteKey == 0)
    {
        DDLogDebug(@"GLPGroup : Remote Key equals zero");
        
        return [otherGroup key] == self.key;
    }
    
    if(self.key == 0 || [otherGroup key] == 0)
    {
        return [otherGroup remoteKey] == self.remoteKey;
    }
    
    return ([otherGroup remoteKey] == self.remoteKey || [otherGroup key] == self.key);
}

- (NSUInteger)hash
{
    return self.remoteKey;
}

-(NSString *)description
{
//    return [NSString stringWithFormat:@"Name: %@, Key: %d, Remote key: %d Description: %@, Privacy: %@, Logged in user: %@, Owner: %@", _name, _key, _remoteKey, _groupDescription, [self privacyToString], _loggedInUser.name, _author.name];
    
    return [NSString stringWithFormat:@"Name: %@, Key: %d, Remote key: %d", _name, _key, _remoteKey];

}

@end
