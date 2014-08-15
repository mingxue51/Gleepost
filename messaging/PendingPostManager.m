//
//  PendingPostManager.m
//  Gleepost
//
//  Created by Σιλουανός on 14/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "PendingPostManager.h"
#import "GLPCategory.h"

@interface PendingPostManager ()

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) GLPCategory *category;

@end

static PendingPostManager *instance = nil;

@implementation PendingPostManager

+ (PendingPostManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PendingPostManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _category = [[GLPCategory alloc] init];
    }
    
    return self;
}

#pragma mark - Modifiers

- (void)setDate:(NSDate *)date
{
    _date = date;
}

#warning implementation pending.

- (void)setCategory:(GLPCategory *)category
{
    _category = category;
}

- (void)reset
{
    instance = [[PendingPostManager alloc] init];
}

@end
