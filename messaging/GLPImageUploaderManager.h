//
//  GLPImageUploaderManager.h
//  Gleepost
//
//  Created by Silouanos on 20/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPImageUploaderManager : NSObject

-(void)uploadImage:(UIImage*)image withTimestamp:(NSDate*)timestamp;

-(NSString*)urlWithTimestamp:(NSDate*)timestamp;
-(void)removeUrlWithTimestamp:(NSDate*)timestamp;
-(void)cancelImageWithTimestamp:(NSDate *)timestamp;

@end
