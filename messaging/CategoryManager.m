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
        
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"news" name:@"News" postRemoteKey:0 andRemoteKey:kGLPNews] forKey:[NSNumber numberWithInt:kGLPNews]];
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"for-sale" name:@"For Sale" postRemoteKey:0 andRemoteKey:kGLPForSale] forKey:[NSNumber numberWithInt:kGLPForSale]];
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"question" name:@"Questions" postRemoteKey:0 andRemoteKey:kGLPQuestion] forKey:[NSNumber numberWithInt:kGLPQuestion]];
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"event" name:@"Event" postRemoteKey:0 andRemoteKey:kGLPEvent] forKey:[NSNumber numberWithInt:kGLPEvent]];
        [tempDict setObject:[[GLPCategory alloc] initWithTag:@"jobs" name:@"Jobs" postRemoteKey:0 andRemoteKey:kGLPJobs] forKey:[NSNumber numberWithInt:kGLPJobs]];

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
