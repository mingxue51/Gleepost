//
//  ThreadMessage.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteEntity.h"
#import "OldUser.h"

@interface ThreadMessage : RemoteEntity

@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) OldUser *user;
@property (assign, nonatomic) NSInteger remoteThreadId;
@property (assign, nonatomic) NSInteger remoteUserId;


@end
