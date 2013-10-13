//
//  MessageManager.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@interface MessageManager : NSObject

+ (void)saveMessage:(Message *)message;

@end
