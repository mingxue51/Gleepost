//
//  GLPFlurryVisibleCellProcessor.h
//  Gleepost
//
//  Created by Silouanos on 07/04/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.

/**
 This class is reponsible to post in Flurry information of a cell if the cell if visible more that 2 seconds.
 */

#import <Foundation/Foundation.h>
#import "GLPPost.h"

@interface GLPFlurryVisibleCellProcessor : NSObject

-(void)addVisiblePosts:(NSArray *)posts;
-(void)resetVisibleCells;

@end
