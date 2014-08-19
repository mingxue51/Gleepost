//
//  GLPVideoUploader.h
//  Gleepost
//
//  Created by Silouanos on 14/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPVideoUploader : NSObject

-(void)uploadVideo:(NSString *)videoPath withTimestamp:(NSDate*)timestamp;

-(NSNumber *)videoKeyWithTimestamp:(NSDate*)timestamp;

-(void)removeUrlWithTimestamp:(NSDate*)timestamp;

-(void)cancelVideoWithTimestamp:(NSDate *)timestamp;

@end
