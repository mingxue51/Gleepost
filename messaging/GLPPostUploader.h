//
//  GLPPostUploader.h
//  Gleepost
//
//  Created by Tanmay Khandelwal on 05/12/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GLPPost;
@class GLPGroup;

@interface GLPPostUploader : NSObject
- (void)startUploadingImage:(UIImage *)image;
- (GLPPost *)uploadPostWithContent:(NSString *)content;
-(void)uploadImageToQueue:(UIImage*)image;
-(GLPPost*)uploadPost:(NSString*)content withCategories:(NSArray*)categories eventTime:(NSDate *)eventDate andTitle:(NSString *)title;
-(GLPPost *)uploadPost:(NSString *)content withCategories:(NSArray *)categories eventTime:(NSDate *)eventDate title:(NSString *)title andGroup:(GLPGroup *)group;

@end
