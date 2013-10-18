//
//  NSMutableArray+QueueAdditions.h
//  Gleepost
//
//  Created by Σιλουανός on 17/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)

- (id) dequeue;
- (void) enqueue:(id)obj;

@end
