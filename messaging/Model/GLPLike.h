//
//  GLPLike.h
//  Gleepost
//
//  Created by Σιλουανός on 22/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPEntity.h"
#import "GLPUser.h"
#import "GLPPost.h"

@interface GLPLike : GLPEntity

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) GLPUser *author;
@property (strong, nonatomic) GLPPost *post;

-(id)initWithUser:(GLPUser*)user withDate:(NSDate*)date andPost:(GLPPost*)post;

@end
