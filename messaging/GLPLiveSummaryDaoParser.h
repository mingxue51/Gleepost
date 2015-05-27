//
//  GLPLiveSummaryDaoParser.h
//  Gleepost
//
//  Created by Silouanos on 25/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPLiveSummary;
@class FMResultSet;

@interface GLPLiveSummaryDaoParser : NSObject

+ (GLPLiveSummary *)createFromResultSet:(FMResultSet *)resultSet;

@end
