//
//  GLPContactDaoParser.h
//  Gleepost
//
//  Created by Σιλουανός on 31/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"
#import "GLPContact.h"

@interface GLPContactDaoParser : NSObject

+ (GLPContact *)createContactFromResultSet:(FMResultSet *)resultSet;
+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPContact *)entity;
@end
