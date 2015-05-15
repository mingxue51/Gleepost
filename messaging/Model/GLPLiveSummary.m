//
//  GLPLiveSummary.m
//  Gleepost
//
//  Created by Silouanos on 15/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This class will preserve all the live data are shown in campus wall top section.

#import "GLPLiveSummary.h"
#import "CategoryManager.h"

@interface GLPLiveSummary ()

@property (assign, nonatomic) NSInteger totalPosts;
@property (strong, nonatomic) NSDictionary *byCategoryPosts;

@end

@implementation GLPLiveSummary

- (id)initWithTotalPosts:(NSInteger)totalPosts andByCategoryData:(NSDictionary *)byCategoryData
{
    self = [super init];
    
    if(self)
    {
        self.totalPosts = totalPosts;
        [self configureCategoriesData:byCategoryData];
    }
    
    return self;
}

- (void)configureCategoriesData:(NSDictionary *)categoryData
{
    NSMutableDictionary *categoryPosts = [[NSMutableDictionary alloc] init];
    
    for(NSString *categoryTag in categoryData)
    {
        GLPCategory *category = [[CategoryManager sharedInstance] categoryWithTag:categoryTag];
        
        if(!category)
        {
            continue;
        }
        
        NSNumber *numberOfPosts = [categoryData objectForKey:categoryTag];
        [categoryPosts setObject:numberOfPosts forKey:@(category.remoteKey)];
    }
    
    self.byCategoryPosts = categoryPosts.mutableCopy;
}

- (NSInteger)speakersPostCount
{
    return [[self.byCategoryPosts objectForKey:@(kGLPSpeakers)] integerValue];
}

- (NSInteger)partiesPostCount
{
    return [[self.byCategoryPosts objectForKey:@(kGLPParties)] integerValue];
}

- (NSInteger)eventsLeftCount
{
    return (self.totalPosts - ([self speakersPostCount] + [self partiesPostCount]));
}

@end
