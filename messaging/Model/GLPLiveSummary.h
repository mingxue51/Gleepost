//
//  GLPLiveSummary.h
//  Gleepost
//
//  Created by Silouanos on 15/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPLiveSummary : NSObject

@property (strong, nonatomic) NSDictionary *byCategoryPosts;

- (id)initWithTotalPosts:(NSInteger)totalPosts andByCategoryData:(NSDictionary *)byCategoryData;
- (id)initWithCategoryData:(NSDictionary *)categoryData;
- (NSInteger)speakersPostCount;
- (NSInteger)partiesPostCount;
- (NSInteger)eventsLeftCount;
- (NSInteger)totalPosts;

@end
