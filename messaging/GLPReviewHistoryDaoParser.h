//
//  GLPReviewHistoryDaoParser.h
//  Gleepost
//
//  Created by Silouanos on 24/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPReviewHistory;
@class FMDatabase;
@class FMResultSet;

@interface GLPReviewHistoryDaoParser : NSObject

+ (GLPReviewHistory *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db;

@end
