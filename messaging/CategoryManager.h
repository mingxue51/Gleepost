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
    kGLPParties = 12
    
}GLPCategories;



@interface CategoryManager : NSObject


+(CategoryManager*)instance;

-(GLPCategory*)categoryWithTag:(NSString*)tag;
-(GLPCategory*)categoryWithRemoteKey:(int)remoteKey;
-(NSArray*)categoriesNames;
-(NSArray*)categoriesTags;
-(NSArray*)getCategories;
-(GLPCategory *)generateEventCategory;


@end
