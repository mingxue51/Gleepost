//
//  GLPGPPostImageLoader.h
//  Gleepost
//
//  Created by Silouanos on 22/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostImageLoader.h"

@interface GLPGPPostImageLoader : PostImageLoader

+ (GLPGPPostImageLoader *)sharedInstance;
- (void)addGroups:(NSArray *)groups;

@end
