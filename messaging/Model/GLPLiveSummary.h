//
//  GLPLiveSummary.h
//  Gleepost
//
//  Created by Silouanos on 15/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPLiveSummary : NSObject

- (id)initWithTotalPosts:(NSInteger)totalPosts andByCategoryData:(NSDictionary *)byCategoryData;
- (NSInteger)speakersPostCount;
- (NSInteger)partiesPostCount;
- (NSInteger)eventsLeftCount;

@end
