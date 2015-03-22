//
//  GLPCampusLiveImageOperation.h
//  Gleepost
//
//  Created by Silouanos on 16/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GLPPostImageOperationDelegate <NSObject>

- (void)operationFinishedWithImage:(UIImage *)image andRemoteKey:(NSInteger)remoteKey;

@end

@interface GLPPostImageOperation : NSOperation

- (id)initWithImageUrl:(NSString *)imageUrl andRemoteKey:(NSInteger)remoteKey;

@property (assign, nonatomic) NSObject<GLPPostImageOperationDelegate> *delegate;

@end
