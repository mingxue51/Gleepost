//
//  CategoryManager.m
//  Gleepost
//
//  Created by Silouanos on 28/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CategoryManager.h"

typedef NS_ENUM(NSInteger, CategoryOrder) {

    kPartiesOrder = 1,
    kMusicOrder = 2,
    kSportsOrder = 3,
    kTheaterOrder = 4,
    kSpeakersOrder = 5,
    kOtherOrder = 6,
    kAllOrder = 7
};

@interface CategoryManager ()

@property (strong, nonatomic) NSDictionary *categories;
@property (strong, nonatomic) NSArray *categoriesInOrder;

/** Represents the selected category appearing in campus wall. */
@property (strong, nonatomic) GLPCategory *selectedCategory;

@end


@implementation CategoryManager

static CategoryManager *instance = nil;

+ (CategoryManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
       instance = [[CategoryManager alloc] init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        //Initialise categories.
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"speaker" name:@"Speakers" postRemoteKey:0 andRemoteKey:kGLPSpeakers] forKey:[NSNumber numberWithInt:kSpeakersOrder]];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"music" name:@"Music" postRemoteKey:0 andRemoteKey:kGLPMusic] forKey:[NSNumber numberWithInt:kMusicOrder]];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"theater" name:@"Theater" postRemoteKey:0 andRemoteKey:kGLPTheater] forKey:[NSNumber numberWithInt:kTheaterOrder]];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"sports" name:@"Sports" postRemoteKey:0 andRemoteKey:kGLPSports] forKey:[NSNumber numberWithInt:kSportsOrder]];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"party" name:@"Parties" postRemoteKey:0 andRemoteKey:kGLPParties] forKey:[NSNumber numberWithInt:kPartiesOrder]];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"other" name:@"Other" postRemoteKey:0 andRemoteKey:kGLPOther] forKey:[NSNumber numberWithInt:kOtherOrder]];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"all" name:@"All" postRemoteKey:0 andRemoteKey:kGLPAll] forKey:[NSNumber numberWithInt:kAllOrder]];

        _categories = [[NSDictionary alloc] initWithDictionary:tempDict];
        
        [self setCategoriesInOrder];
        
        _selectedCategory = nil;
    }
    
    return self;
}

- (void)setCategoriesInOrder
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    // get all keys into array
    NSArray * categoriesKey = [_categories allKeys];
    
    // sort it
    NSArray *sortedCategoriesKeys = [categoriesKey sortedArrayUsingSelector:@selector(compare:)];
    
    
    for(NSNumber *key in sortedCategoriesKeys)
    {
        [array addObject:[_categories objectForKey:key]];
    }
    
    _categoriesInOrder = array.mutableCopy;
    
}

-(GLPCategory*)categoryWithTag:(NSString*)tag
{
    for(GLPCategory *c in _categories)
    {
        if([c.tag isEqualToString:tag])
        {
            return c;
        }
    }
    
    return nil;
}

-(GLPCategory*)categoryWithOrderKey:(int)remoteKey
{
    return [_categories objectForKey:[NSNumber numberWithInt:remoteKey]];
}

-(NSArray*)categoriesNames
{
    NSMutableArray *names = [NSMutableArray array];
    
    for(NSNumber *remoteKey in _categories)
    {
        
        [names addObject: ((GLPCategory*)[_categories objectForKey:remoteKey]).name];
    }
    
    return names;
}

-(NSArray*)categoriesTags
{
    NSMutableArray *tags = [NSMutableArray array];
    
    for(NSNumber *remoteKey in _categories)
    {
        [tags addObject: ((GLPCategory*)[_categories objectForKey:remoteKey]).tag];
    }
    
    return tags;
}

-(NSArray*)getCategories
{
    return _categoriesInOrder;
}

- (NSMutableArray *)getCategoriesForFilteringView
{
    NSMutableArray *finalCategories = [[NSMutableArray alloc] init];
    
    for (GLPCategory *category in _categoriesInOrder)
    {
        if(![category.name isEqualToString:@"Other"])
        {
            [finalCategories addObject:category];
        }
    }
    
    return finalCategories;
}

-(GLPCategory *)generateEventCategory
{
    return [[GLPCategory alloc] initWithTag:@"event" name:@"Event" postRemoteKey:0 andRemoteKey:5];
}

#pragma mark - Accesssors

- (NSString *)selectedCategoryName
{
    return [_selectedCategory tag];
}




//-(NSString*)tagFromRemoteKey:(GLPCategories)remotekey
//{
//    switch(remotekey) {
//        case kGLPNews:
//            return ;
//            break;
//            
//        case kGLPForSale:
//            result = @"b";
//            break;
//            
//        case kGLPQuestion:
//            result = @"c";
//            break;
//            
//        case kGLPEvent:
//            result = @"c";
//            break;
//            
//        case kGLPJobs:
//            result = @"c";
//            break;
//            
//        default:
//            result = @"unknown";
//    }
//    
//    return result;
//}

@end
