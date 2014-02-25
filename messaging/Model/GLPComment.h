//
//  GLPComment.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPEntity.h"
#import "GLPUser.h"
#import "GLPPost.h"

@interface GLPComment : GLPEntity

@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) GLPUser *author;
@property (strong, nonatomic) GLPPost *post;
@property (assign, nonatomic) SendStatus sendStatus;

@end
