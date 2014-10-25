//
//  GLPMember.m
//  Gleepost
//
//  Created by Silouanos on 09/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPMember.h"

@implementation GLPMember

- (id)initWithName:(NSString *)name withId:(NSInteger)key imageUrl:(NSString *)imgUrl andRoleLevelNumber:(NSInteger)roleNumber
{
    self = [super initWithName:name withId:key andImageUrl:imgUrl];
    
    if(self)
    {
        [self configureRoleWithNumber:roleNumber];
    }
    
    return self;
}

- (id)initWithName:(NSString *)name withGroupRemoteKey:(NSInteger)groupRemoteKey imageUrl:(NSString *)imgUrl andRoleLevelNumber:(NSInteger)roleNumber
{
    self = [super initWithName:name withId:0 andImageUrl:imgUrl];
    
    if(self)
    {
        _groupRemoteKey = groupRemoteKey;
        [self configureRoleWithNumber:roleNumber];
    }
    
    return self;
}

- (id)initWithUser:(GLPUser *)user andRoleNumber:(NSInteger)roleNumber
{
    self = [super initWithUser:user];
    
    if(self)
    {
        [self configureRoleWithNumber:roleNumber];
    }
    
    return self;
}

- (void)setRoleKey:(NSInteger)roleLevel
{
    [self configureRoleWithNumber:roleLevel];
}

- (void)configureRoleWithNumber:(NSInteger)roleNumber
{
    switch (roleNumber)
    {
        case 1:
            _roleName = @"Member";
            _roleLevel = kMember;
            break;
            
        case 8:
            _roleName = @"Admin";
            _roleLevel = kAdministrator;
            break;
            
        case 9:
            _roleName = @"Owner";
            _roleLevel = kCreator;
            break;
        default:
            break;
    }
}

- (BOOL)isAuthenticatedForChanges
{
    if (_roleLevel == kAdministrator || _roleLevel == kCreator)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isMemberOfGroup
{
    if(_roleName)
    {
        return YES;
    }
    
    return NO;
}

/**
 Casts the GLPMember to GLPUser data type and returns it.
 
 @return user
 
 */
- (GLPUser *)getUser
{
    DDLogDebug(@"User from member: %@", (GLPUser *)self);
    
    return (GLPUser *)self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Name %@, Group remote key %ld", self.name, (long)_groupRemoteKey];
}

@end
