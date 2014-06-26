//
//  ImageFormatterHelper.h
//  Gleepost
//
//  Created by Σιλουανός on 11/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface ImageFormatterHelper : NSObject

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToHeight: (float) finalHeight;
+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width;
+(UIImage*)generateOnePixelHeightImageWithColour:(UIColor*)colour;
+ (UIImage *)generateImageWithColour:(UIColor *)colour;
+(UIImage*)resizeImage:(UIImage*)image withSize:(CGSize)newSize;
+(UIImage*)cropImage:(UIImage*)image withRect:(CGRect)cropRect;
+(UIImage *)convertToGrayscale:(UIImage *) originalImage inRect: (CGRect) rect;
+(UIImage *)fadeOutEffectInBottomOfImage:(UIImage *)originalImage inRect:(CGRect)rect;
+ (UIImage *) addImageToImage:(UIImage *)img withImage2:(UIImage *)img2 withImageView:(UIImageView *)imageView andRect:(CGRect)cropRect;

+ (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;

@end
