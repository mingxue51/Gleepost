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
    kGLPNews = 2,
    kGLPForSale = 3,
    kGLPQuestion = 4,
    kGLPEvent = 5,
    kGLPJobs = 6
    
}GLPCategories;

@interface CategoryManager : NSObject


+(CategoryManager*)instance;

-(GLPCategory*)categoryWithTag:(NSString*)tag;
-(GLPCategory*)categoryWithRemoteKey:(int)remoteKey;
-(NSArray*)categoriesNames;
-(NSArray*)categoriesTags;
-(NSArray*)getCategories;


@end
