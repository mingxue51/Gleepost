//
//  GLPMember.h
//  Gleepost
//
//  Created by Silouanos on 09/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPUser.h"

typedef NS_ENUM(NSUInteger, MemberRole) {
    kMember = 1,
    kAdministrator = 8,
    kCreator = 9
};

@interface GLPMember : GLPUser

@property (assign, nonatomic) MemberRole roleLevel;
@property (strong, nonatomic) NSString *roleName;
@property (assign, nonatomic) NSInteger groupRemoteKey;

//- (id)initWithName:(NSString *)name withId:(NSInteger)key imageUrl:(NSString *)imgUrl andRoleLevelNumber:(NSInteger)roleNumber;
- (id)initWithName:(NSString *)name withGroupRemoteKey:(NSInteger)groupRemoteKey imageUrl:(NSString *)imgUrl andRoleLevelNumber:(NSInteger)roleNumber;
- (id)initWithUser:(GLPUser *)user andRoleNumber:(NSInteger)roleNumber;

- (void)setRoleKey:(NSInteger)roleLevel;
- (GLPUser *)getUser;

@end
