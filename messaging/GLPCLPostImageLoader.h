//
//  GLPCLPostImageLoader.h
//  Gleepost
//
//  Created by Silouanos on 16/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPCLPostImageLoader : NSObject

+ (GLPCLPostImageLoader *)sharedInstance;
- (void)addPosts:(NSArray *)posts;

@end
