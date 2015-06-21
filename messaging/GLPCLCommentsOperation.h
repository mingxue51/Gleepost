//
//  GLPCLCommentsOperation.h
//  Gleepost
//
//  Created by Silouanos on 11/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPost;

@protocol GLPCLCommentsOperationDelegate <NSObject>

@required
- (void)comments:(NSArray *)comments forPost:(GLPPost *)post;

@end

@interface GLPCLCommentsOperation : NSOperation

- (id)initWithPost:(GLPPost *)post;

@property (assign, nonatomic) NSObject<GLPCLCommentsOperationDelegate> *delegate;

@end
