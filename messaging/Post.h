//
//  Post.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialContent.h"
#import "RemoteEntity.h"
#import "User.h"

@interface Post : RemoteEntity

@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) SocialContent *socialContent;
@property (assign, nonatomic) NSInteger commentsCount;
@property (strong, nonatomic) NSArray *imagesUrls;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) User *user;

@end
