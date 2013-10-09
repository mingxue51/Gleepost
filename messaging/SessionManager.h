//
//  SessionManager.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface SessionManager : NSObject

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSString *token;

+ (SessionManager *)sharedInstance;

@end
