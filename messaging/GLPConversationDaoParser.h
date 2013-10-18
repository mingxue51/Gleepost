//
//  GLPConversationDaoParser.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPConversation.h"
#import "FMResultSet.h"

@interface GLPConversationDaoParser : NSObject

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPConversation *)entity;
+ (GLPConversation *)createFromResultSet:(FMResultSet *)resultSet;

@end
