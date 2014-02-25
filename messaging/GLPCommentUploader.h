//
//  GLPCommentUploader.h
//  Gleepost
//
//  Created by Silouanos on 25/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPComment.h"
#import "GLPPost.h"

@interface GLPCommentUploader : NSObject

-(GLPComment *)uploadCommentWithContent:(NSString *)content andPost:(GLPPost *)post;

@end
