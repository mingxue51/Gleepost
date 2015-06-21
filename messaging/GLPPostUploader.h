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
@class GLPCategory;
@class GLPLocation;

@interface GLPPostUploader : NSObject

-(void)uploadImageToQueue:(UIImage*)image;
-(GLPPost*)uploadPost:(NSString*)content withCategories:(NSArray *)categories eventTime:(NSDate *)eventDate title:(NSString *)title andLocation:(GLPLocation *)location;
-(GLPPost *)uploadPost:(NSString *)content withCategories:(NSArray *)categories eventTime:(NSDate *)eventDate title:(NSString *)title group:(GLPGroup *)group andLocation:(GLPLocation *)location;
- (void)uploadPollPostWithPost:(GLPPost *)post;
-(void)uploadVideoInPath:(NSString *)path;

@end
