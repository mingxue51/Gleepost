//
//  CategoryManager.m
//  Gleepost
//
//  Created by Silouanos on 28/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CategoryManager.h"

@interface CategoryManager ()

@property (strong, nonatomic) NSDictionary *categories;


@end


@implementation CategoryManager

static CategoryManager *instance = nil;

+ (CategoryManager *)instance
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
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"speaker" name:@"Speakers" postRemoteKey:0 andRemoteKey:kGLPSpeakers] forKey:[NSNumber numberWithInt:kGLPSpeakers]];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"music" name:@"Music" postRemoteKey:0 andRemoteKey:kGLPMusic] forKey:[NSNumber numberWithInt:kGLPMusic]];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"theater" name:@"Theater" postRemoteKey:0 andRemoteKey:kGLPTheater] forKey:[NSNumber numberWithInt:kGLPTheater]];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"sports" name:@"Sports" postRemoteKey:0 andRemoteKey:kGLPSports] forKey:[NSNumber numberWithInt:kGLPSports]];
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"party" name:@"Parties" postRemoteKey:0 andRemoteKey:kGLPParties] forKey:[NSNumber numberWithInt:kGLPParties]];

        _categories = [[NSDictionary alloc] initWithDictionary:tempDict];
    }
    
    return self;
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

-(GLPCategory*)categoryWithRemoteKey:(int)remoteKey
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
    NSMutableArray *categories = [NSMutableArray array];
    
    for(NSNumber *remoteKey in _categories)
    {
        [categories addObject: [_categories objectForKey:remoteKey]];
    }
    
    return categories;
}

-(GLPCategory *)generateEventCategory
{
    return [[GLPCategory alloc] initWithTag:@"event" name:@"Event" postRemoteKey:0 andRemoteKey:5];
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
