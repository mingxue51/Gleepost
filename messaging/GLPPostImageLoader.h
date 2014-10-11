//
//  GLPPostImageLoader.h
//  Gleepost
//
//  Created by Silouanos on 14/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"
#import "GLPImageLoader.h"

@interface GLPPostImageLoader : GLPImageLoader

+ (GLPPostImageLoader *)sharedInstance;

-(void)addPostsImages:(NSArray*)posts;



@end
