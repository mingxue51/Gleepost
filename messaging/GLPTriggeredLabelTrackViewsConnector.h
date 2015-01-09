//
//  GLPTriggeredLabelTrackViewsConnector.h
//  Gleepost
//
//  Created by Silouanos on 09/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPTriggeredLabelTrackViewsConnector : NSObject

+ (GLPTriggeredLabelTrackViewsConnector *)sharedInstance;
- (void)trackPost:(NSInteger)postRemoteKey;
- (NSInteger)currentPostRemoteKey;
- (BOOL)needsToAddRemoteKey:(NSInteger)postRemoteKey;

@end
