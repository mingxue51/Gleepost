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
    kGLPGeneral = 1,
    kGLPQuestions = 18
    
}GLPCategories;

typedef NS_ENUM(NSInteger, CategoryOrder) {
    
    kAllOrder = 1,
    kPartiesOrder = 2,
    kFreeFood = 3,
    kSportsOrder = 4,
    kSpeakersOrder = 5,
    kMusicOrder = 6,
    kTheaterOrder = 7,
    kAnnouncementsOrder = 8,
    kGeneralOrder = 9,
    kQuestionsOrder = 10,
    kOtherOrder = 11
};


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
