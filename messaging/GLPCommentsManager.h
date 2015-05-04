//
//  GLPCommentsManager.h
//  Gleepost
//
//  Created by Silouanos on 04/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPost;

@interface GLPCommentsManager : NSObject

- (instancetype)initWithPost:(GLPPost *)post;

@end
