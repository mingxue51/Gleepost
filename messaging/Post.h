//
//  Post.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Thread.h"
#import "SocialContent.h"

@interface Post : Thread

@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) SocialContent *socialContent;

@end
