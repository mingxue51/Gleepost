//
//  GLPReviewHistoryDao.h
//  Gleepost
//
//  Created by Silouanos on 24/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GLPReviewHistory;
@class GLPPost;

@interface GLPReviewHistoryDao : NSObject

+ (NSArray *)findReviewHistoryWithPostRemoteKey:(NSInteger)postRemoteKey;
+ (void)saveReviewHistory:(GLPReviewHistory *)reviewHistory withPost:(GLPPost *)post;
+ (void)saveReviewHistoryArrayOfPost:(GLPPost *)post;
+ (void)removeReviewHistoryWithPost:(GLPPost *)post;
+ (void)deleteReviewHistoryTable;
@end
