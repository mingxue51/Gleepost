//
//  Comment.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreadMessage.h"
#import "SocialContent.h"

@interface Comment : ThreadMessage

@property (strong, nonatomic) SocialContent *socialContent;

@end