//
//  GLPGroupImageLoader.h
//  Gleepost
//
//  Created by Silouanos on 10/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPImageLoader.h"

@interface GLPGroupImageLoader : GLPImageLoader

+ (GLPGroupImageLoader *)sharedInstance;

- (void)addGroupsImages:(NSArray *)groups;

@end
