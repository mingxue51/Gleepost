//
//  GLPPostUploader.h
//  Gleepost
//
//  Created by Lukas on 11/14/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"

@interface GLPPostUploader : NSObject

- (void)uploadImage:(UIImage *)image;
- (void)uploadPostWithContent:(NSString *)content hasImage:(BOOL)hasImage;

@end
