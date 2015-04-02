//
//  CategoryManager.h
//  Gleepost
//
//  Created by Silouanos on 28/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPCategory.h"

typedef enum
{
    kGLPSpeakers = 8,
    kGLPMusic = 9,
    kGLPTheater = 10,
    kGLPSports = 11,
    kGLPParties = 12,
    kGLPFreeFood = 13,
    kGLPAnnouncements = 14,
    kGLPOther = 15,
    kGLPAll = 16,
    kGLPGeneral = 17,
    kGLPQuestions = 18
    
}GLPCategories;



@interface CategoryManager : NSObject

+(CategoryManager*)sharedInstance;

- (GLPCategory*)categoryWithOrderKey:(NSInteger)remoteKey;
- (GLPCategory *)setSelectedCategoryWithOrderKey:(NSInteger)orderKey;
- (void)setSelectedCategory:(GLPCategory *)category;
-(NSArray*)getCategories;
- (NSMutableArray *)getCategoriesForFilteringView;
-(GLPCategory *)generateEventCategory;
- (NSString *)selectedCategoryName;
- (GLPCategory *)selectedCategory;
- (void)reset;

@end
