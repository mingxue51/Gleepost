//
//  GLPImageCacheHelper.m
//  Gleepost
//
//  Created by Silouanos on 27/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Static class helps on the SDWebImageCache operations.

#import "GLPImageCacheHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation GLPImageCacheHelper

+ (void)storeImage:(UIImage *)image withImageUrl:(NSString *)imageUrl
{
    [[SDImageCache sharedImageCache] storeImage:image forKey:imageUrl];
}

+ (void)removeImageWithUrl:(NSString *)imageUrl
{
    [[SDImageCache sharedImageCache] removeImageForKey:imageUrl];
}

+ (void)replaceImage:(UIImage *)image withImageUrl:(NSString *)imageUrl andOldImageUrl:(NSString *)oldImageUrl
{
    [GLPImageCacheHelper removeImageWithUrl:oldImageUrl];
    [GLPImageCacheHelper storeImage:image withImageUrl:imageUrl];
}

+ (UIImage *)imageWithUrl:(NSString *)imageUrl
{
    return [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageUrl];
}

@end
