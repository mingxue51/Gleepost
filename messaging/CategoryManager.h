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
    kGLPOther = 13,
    kGLPAll = 14
    
}GLPCategories;



@interface CategoryManager : NSObject


+(CategoryManager*)sharedInstance;

-(GLPCategory*)categoryWithTag:(NSString*)tag;
-(GLPCategory*)categoryWithOrderKey:(int)remoteKey;
-(NSArray*)categoriesNames;
-(NSArray*)categoriesTags;
-(NSArray*)getCategories;
- (NSMutableArray *)getCategoriesForFilteringView;
-(GLPCategory *)generateEventCategory;
- (void)setSelectedCategory:(GLPCategory *)selectedCategory;
- (NSString *)selectedCategoryName;
- (GLPCategory *)selectedCategory;


@end
