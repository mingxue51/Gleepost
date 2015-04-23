//
//  GLPPollDaoParser.h
//  Gleepost
//
//  Created by Silouanos on 23/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class FMResultSet;
@class GLPPoll;

@interface GLPPollDaoParser : NSObject

+ (GLPPoll *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db;
+ (GLPPoll *)updateWithOptionsVotesFromResultSet:(FMResultSet *)resultSet withPoll:(GLPPoll *)poll inDb:(FMDatabase *)db;

@end
