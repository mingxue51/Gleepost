//
//  GLPLiveConversationDaoParser.h
//  Gleepost
//
//  Created by Σιλουανός on 28/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPLiveConversation.h"
#import "FMResultSet.h"
@interface GLPLiveConversationDaoParser : NSObject

+ (GLPLiveConversation *)createFromResultSet:(FMResultSet *)resultSet;

@end
