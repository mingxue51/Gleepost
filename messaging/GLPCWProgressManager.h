//
//  GLPCWProgressManager.h
//  Gleepost
//
//  Created by Silouanos on 21/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"
#import "UploadingProgressView.h"

@interface GLPCWProgressManager : NSObject

@property (strong, nonatomic) NSDate *currentProcessedTimestamp;
@property (strong, nonatomic) UploadingProgressView *progressView;
@property (assign, nonatomic, getter=isPostButtonClicked) BOOL postClicked;
@property (assign, nonatomic, getter = isProgressFinished) BOOL progressFinished;
@property (strong, nonatomic) GLPPost *pendingPost;
/** This object is used only when the video is uploaded and don't viewed to user.*/
@property (strong, nonatomic) NSDate *uploadedVideoTimestamp;

+ (GLPCWProgressManager *)sharedInstance;

- (void)configureObjects;
- (NSDate *)registeredTimestamp;
- (void)setThumbnailImage:(UIImage *)thumbnail;
- (void)progressFinished;
- (void)postButtonClicked;
- (void)showProgressView;
- (void)hideProgressView;

@end
