//
//  GLPTriggeredLabelTrackViewsConnector.m
//  Gleepost
//
//  Created by Silouanos on 09/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This class helps the interoperability between GLPTrackViewsCountProcessor and GLPTriggeredLabel.

#import "GLPTriggeredLabelTrackViewsConnector.h"

@interface GLPTriggeredLabelTrackViewsConnector ()

@property (assign, nonatomic) NSInteger postRemoteKey;

@end

@implementation GLPTriggeredLabelTrackViewsConnector

static GLPTriggeredLabelTrackViewsConnector *instance = nil;

+ (GLPTriggeredLabelTrackViewsConnector *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPTriggeredLabelTrackViewsConnector alloc] init];
    });
    
    return instance;
}

- (void)trackPost:(NSInteger)postRemoteKey
{
    if(_postRemoteKey == postRemoteKey)
    {
        return;
    }
    
    DDLogDebug(@"trackPost triggered %ld", (long)postRemoteKey);
    
    _postRemoteKey = postRemoteKey;
}

- (NSInteger)currentPostRemoteKey
{
    return _postRemoteKey;
}

- (BOOL)needsToAddRemoteKey:(NSInteger)postRemoteKey
{
    if(_postRemoteKey == postRemoteKey)
    {
        return NO;
    }
    
    return YES;
}

@end
