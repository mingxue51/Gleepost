//
//  GLPVideoManager.m
//  Gleepost
//
//  Created by Silouanos on 13/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//  This manager has the responsibility to take care of all recorded videos.
//  It supports operations such as saving the path of a new recorded vivdo.
//

#import "GLPVideoManager.h"

@interface GLPVideoManager ()

@property (strong, nonatomic) NSMutableDictionary *localSavedVideos;

@end

@implementation GLPVideoManager

static GLPVideoManager *instance = nil;

+(GLPVideoManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPVideoManager alloc] init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        [self initialiseObjects];
    }
    
    return self;
}

-(void)initialiseObjects
{
    _localSavedVideos = [[NSMutableDictionary alloc] init];
}

#pragma mark - Modifiers

-(void)addVideoWithPath:(NSString *)path
{
    NSDate *timestamp = [NSDate date];
    
    [_localSavedVideos setObject:path forKey:timestamp];
}






@end
