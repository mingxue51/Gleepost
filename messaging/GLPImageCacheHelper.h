//
//  GLPImageCacheHelper.h
//  Gleepost
//
//  Created by Silouanos on 27/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPImageCacheHelper : NSObject

+ (void)storeImage:(UIImage *)image withImageUrl:(NSString *)imageUrl;

+ (void)removeImageWithUrl:(NSString *)imageUrl;

+ (void)replaceImage:(UIImage *)image withImageUrl:(NSString *)imageUrl andOldImageUrl:(NSString *)oldImageUrl;

+ (UIImage *)imageWithUrl:(NSString *)imageUrl;

@end
