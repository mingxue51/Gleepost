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
#import "GLPUser.h"

@interface GLPGroup : GLPEntity

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *groupDescription;
@property (strong, nonatomic) NSString *groupImageUrl;
@property (assign, nonatomic) SendStatus sendStatus;
@property (strong, nonatomic) UIImage *finalImage;
@property (assign, nonatomic) BOOL isFromPushNotification;

//Not create in local database
@property (strong, nonatomic) GLPUser *author;

-(id)initWithName:(NSString *)name andRemoteKey:(int)remoteKey;
- (id)initFromPushNotificationWithRemoteKey:(NSInteger)remoteKey;

@end
