//
//  RemoteMessage.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SendStatus.h"

@class RemoteConversation, RemoteUser;

@interface RemoteMessage : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * remoteKey;
@property (nonatomic, retain) NSNumber * seen;
@property (nonatomic, retain) NSNumber * sendStatus;
@property (nonatomic, retain) RemoteConversation *conversation;
@property (nonatomic, retain) RemoteUser *author;

@end
