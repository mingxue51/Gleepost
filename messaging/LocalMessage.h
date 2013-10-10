//
//  LocalMessage.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RemoteMessage;

@interface LocalMessage : NSManagedObject

@property (nonatomic, retain) RemoteMessage *remoteMessage;

@end
