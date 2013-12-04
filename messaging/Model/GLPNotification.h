//
//  GLPNotification.h
//  Gleepost
//
//  Created by Lukas on 11/13/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPEntity.h"
#import "GLPUser.h"

@interface GLPNotification : GLPEntity

typedef enum {
    kGLPNotificationTypeAddedYou, //0
    kGLPNotificationTypeAcceptedYou, //1
    kGLPNotificationTypeCommented, //2
    kGLPNotificationTypeLiked, //3
    kGLPNotificationTypeContacts, //4
} GLPNotificationType;

@property (assign, nonatomic) NSInteger postRemoteKey;
@property (assign, nonatomic) GLPNotificationType notificationType;
@property (assign, nonatomic) BOOL seen;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) GLPUser *user;

- (BOOL)hasAction;
- (NSString *)notificationTypeDescription;
- (void)alreadyContacts;

@end
