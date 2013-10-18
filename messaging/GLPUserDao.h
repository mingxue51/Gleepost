//
//  GLPUserDao.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPUser.h"

@interface GLPUserDao : NSObject

+ (GLPUser *)findByRemoteKey:(NSInteger)remoteKey;
+ (void)save:(GLPUser *)entity;

@end
