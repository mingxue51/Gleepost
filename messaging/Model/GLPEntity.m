//
//  GLPEntity.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPEntity.h"

@implementation GLPEntity

@synthesize key = _key;
@synthesize remoteKey = _remoteKey;

NSString * const GLPKeyColumn = @"key";
NSString * const GLPRemoteKeyColumn = @"remoteKey";

- (BOOL) isEqualToEntity:(GLPEntity *)entity
{
    if(self == entity) {
        return YES;
    }
    
    if(self.remoteKey == entity.remoteKey) {
        return YES;
    }
    
    return NO;
}

@end
