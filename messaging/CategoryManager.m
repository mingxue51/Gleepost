//
//  CategoryManager.m
//  Gleepost
//
//  Created by Silouanos on 28/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CategoryManager.h"

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
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"food" name:@"Free Food" postRemoteKey:0 andRemoteKey:kGLPFreeFood] forKey:[NSNumber numberWithInt:kFreeFood]];

        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"other" name:@"Other" postRemoteKey:0 andRemoteKey:kGLPOther] forKey:[NSNumber numberWithInt:kOtherOrder]];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"all" name:@"All" postRemoteKey:0 andRemoteKey:kGLPAll] forKey:[NSNumber numberWithInt:kAllOrder]];

        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"announcements" name:@"Announcements" postRemoteKey:0 andRemoteKey:kGLPAnnouncements]  forKey:@(kAnnouncementsOrder)];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"general" name:@"General" postRemoteKey:0 andRemoteKey:kGLPGeneral]  forKey:@(kGeneralOrder)];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"questions" name:@"Questions" postRemoteKey:0 andRemoteKey:kGLPQuestions]  forKey:@(kQuestionsOrder)];


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

- (GLPCategory *)categoryWithOrderKey:(NSInteger)orderKey
{
    return [_categories objectForKey:[NSNumber numberWithInteger:orderKey]];
}

/**
 Sets the category and returns the category as a GLPCategory instance.
 
 @param orderKey the category key that is defined in CategoryOrder enum.
 
 */
- (GLPCategory *)setSelectedCategoryWithOrderKey:(NSInteger)orderKey
{
    GLPCategory *selectedCategory = [self categoryWithOrderKey:orderKey];
    
    if([selectedCategory.tag isEqualToString:@"all"])
    {
        [self setSelectedCategory:nil];
    }
    else
    {
        [self setSelectedCategory:selectedCategory];
    }
    
    return [_categories objectForKey:@(orderKey)];
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

- (void)reset
{
    _selectedCategory = nil;
}

- (NSString *)selectedCategoryName
{
    return [_selectedCategory tag];
}

@end
