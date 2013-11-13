//
//  GLPNotificationDaoParser.h
//  Gleepost
//
//  Created by Lukas on 11/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPNotification.h"
#import "FMDatabase.h"

@interface GLPNotificationDaoParser : NSObject

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPNotification *)entity inDb:(FMDatabase *)db;
+ (GLPNotification *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db;

@end