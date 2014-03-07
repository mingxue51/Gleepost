//
//  GLPOperationManager.h
//  Gleepost
//
//  Created by Σιλουανός on 6/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  Programmers should inherits from this class only for operations manager classes.
//  That is, classes that have the ability of asynchronous operations using an NSTimer.
//  Current children classes: GroupOperationManager.

#import <Foundation/Foundation.h>
#import "GLPImageUploaderManager.h"

@interface GLPOperationManager : NSObject

@property (strong, nonatomic) GLPImageUploaderManager *imageUploader;
@property (strong, nonatomic) NSTimer *checkForUploadingTimer;
@property (assign, nonatomic) BOOL isNetworkAvailable;


-(void)uploadImage:(UIImage *)image withTimestamp:(NSDate *)timestamp;
-(void)stopTimer;

@end
