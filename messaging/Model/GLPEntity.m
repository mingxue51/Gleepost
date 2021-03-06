//
//  GLPEntity.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPEntity.h"

@implementation GLPEntity

@synthesize key=_key;
@synthesize remoteKey=_remoteKey;

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _key = 0;
    _remoteKey = 0;
    
    return self;
}

- (NSNumber *)keyNumber
{
    return [NSNumber numberWithInteger:_key];
}

- (NSNumber *)remoteKeyNumber
{
    return [NSNumber numberWithInteger:_remoteKey];
}

- (BOOL) isEqualToEntity:(GLPEntity *)entity
{
    if(self == entity) {
        return YES;
    }
    
    if(_key != 0 && _key == entity.key) {
        return YES;
    }
    
    if(_remoteKey != 0 && _remoteKey == entity.remoteKey) {
        return YES;
    }
    
    return NO;
}


# pragma mark - Copy

-(id)copyWithZone:(NSZone *)zone
{
    GLPEntity *object = [[self class] allocWithZone:zone];
    object.key = _key;
    object.remoteKey = _remoteKey;
    
    return object;
}

@end
