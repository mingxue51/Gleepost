//
//  GLPCommentsManager.h
//  Gleepost
//
//  Created by Silouanos on 04/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPost;
@class GLPComment;

@interface CLCommentsManager : NSObject

- (void)loadCommentsWithPost:(GLPPost *)post;
- (GLPComment *)commentAtIndex:(NSInteger)index withPost:(GLPPost *)post;
- (NSInteger)commentsCountWithPost:(GLPPost *)post;

@end
