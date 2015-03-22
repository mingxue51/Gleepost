//
//  WebClientJSON.h
//  Gleepost
//
//  Created by Silouanos on 22/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "AFHTTPClient.h"

@interface WebClientJSON : AFHTTPClient

+ (WebClientJSON *)sharedInstance;

- (void)visibleViewsWithPosts:(NSArray *)posts withCallbackBlock:(void (^)(BOOL success))callback;

@end
