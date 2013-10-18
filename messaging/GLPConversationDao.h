//
//  GLPConversationDao.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPConversation.h"

@interface GLPConversationDao : NSObject

+ (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey;
+ (NSArray *)findAllOrderByDate;
+ (void)save:(GLPConversation *)entity;
+ (void)replaceAllConversationsWith:(NSArray *)conversations;

@end
