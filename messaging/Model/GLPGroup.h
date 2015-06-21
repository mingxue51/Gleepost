//
//  GLGroup.h
//  Gleepost
//
//  Created by Σιλουανός on 3/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPEntity.h"
#import "SendStatus.h"
#import "GLPMember.h"

typedef NS_ENUM(NSUInteger, GroupPrivacy) {
    kPublicGroup = 0,
    kPrivateGroup = 1,
    kSecretGroup = 2
};

@interface GLPGroup : GLPEntity

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *groupDescription;
@property (strong, nonatomic) NSString *groupImageUrl;
@property (assign, nonatomic) SendStatus sendStatus;
@property (strong, nonatomic) UIImage *pendingImage;
@property (strong, nonatomic) UIImage *loadedImage;
@property (assign, nonatomic) BOOL isFromPushNotification;
@property (assign, nonatomic) NSInteger unreadNewPosts;
@property (assign, nonatomic) NSInteger membersCount;
@property (assign, nonatomic) GroupPrivacy privacy;
@property (assign, nonatomic) NSInteger conversationRemoteKey;
@property (strong, nonatomic) NSDate *lastActivity;

//Not create in local database
@property (strong, nonatomic) GLPMember *loggedInUser;

@property (strong, nonatomic) GLPMember *author;

- (id)initWithName:(NSString *)name andRemoteKey:(NSInteger)remoteKey;
- (id)initFromPushNotificationWithRemoteKey:(NSInteger)remoteKey;
- (NSString *)privacyToString;
- (NSString *)generatePendingIdentifier;
- (void)setPrivacyWithString:(NSString *)privacy;

@end
