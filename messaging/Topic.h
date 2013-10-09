//
//  Topic.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Thread.h"

@interface Topic : Thread

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *users;

@end
