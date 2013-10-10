//
//  MessageManager.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteMessage.h"

@interface MessageManager : NSObject

+ (void)saveMessage:(RemoteMessage *)message;

@end
