//
//  ImageFormatterHelper.m
//  Gleepost
//
//  Created by Σιλουανός on 11/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ImageFormatterHelper.h"
#import "UIImage+Alpha.h"

@implementation ImageFormatterHelper

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToHeight: (float) finalHeight
{
    float oldHeight = sourceImage.size.height;
    float scaleFactor = finalHeight / oldHeight;
    
    float newWidth = sourceImage.size.width * scaleFactor;
    //float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, finalHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, finalHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    //float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(i_width, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, i_width, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(UIImage*)generateOnePixelHeightImageWithColour:(UIColor*)colour
{
    CGSize imageSize = CGSizeMake(320, 0.5);
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [colour setFill];
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(UIImage*)resizeImage:(UIImage*)image withSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+(UIImage*)cropImage:(UIImage*)image withRect:(CGRect)cropRect
{
    UIImage *cropedImage = nil;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    // or use the UIImage wherever you like
    cropedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropedImage;
}

+ (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef imgRef = [image CGImage];
    CGImageRef maskRef = [maskImage CGImage];
    CGImageRef actualMask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                              CGImageGetHeight(maskRef),
                                              CGImageGetBitsPerComponent(maskRef),
                                              CGImageGetBitsPerPixel(maskRef),
                                              CGImageGetBytesPerRow(maskRef),
                                              CGImageGetDataProvider(maskRef), NULL, false);
    CGImageRef masked = CGImageCreateWithMask(imgRef, actualMask);
    return [UIImage imageWithCGImage:masked];
    
}

+ (UIImage *) addImageToImage:(UIImage *)img withImage2:(UIImage *)img2 withImageView:(UIImageView *)imageView andRect:(CGRect)cropRect{

    
    CGSize size = CGSizeMake(imageView.image.size.width, imageView.image.size.height);
    UIGraphicsBeginImageContext(size);
    
    img2 = [img2 setAlpha:0.5];
    
    CGPoint pointImg1 = CGPointMake(100,0);
    [img drawAtPoint:pointImg1];
    
    CGPoint pointImg2 = cropRect.origin;
    [img2 drawAtPoint: pointImg2];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

+(UIImage *)fadeOutEffectInBottomOfImage:(UIImage *)originalImage inRect:(CGRect)rect
{
    CGSize size = [originalImage size];
    int width = size.width;
    int height = size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [originalImage CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            if(x > rect.origin.x && y > rect.origin.y && x < rect.origin.x + rect.size.width && y < rect.origin.y + rect.size.height) {
                
                int alpha = 0;
                
//                uint32_t fade_out = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
                uint32_t fade_out = rgbaPixel[RED] + rgbaPixel[GREEN] + rgbaPixel[BLUE] - alpha;

                // set the pixels to gray in your rect
                
                rgbaPixel[RED] = fade_out;
                rgbaPixel[GREEN] = fade_out;
                rgbaPixel[BLUE] = fade_out;
                
                alpha += 20;
            }
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
    
}

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

+(UIImage *)convertToGrayscale:(UIImage *) originalImage inRect: (CGRect) rect
{
    CGSize size = [originalImage size];
    int width = size.width;
    int height = size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [originalImage CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            if(x > rect.origin.x && y > rect.origin.y && x < rect.origin.x + rect.size.width && y < rect.origin.y + rect.size.height) {
                
                // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
                
                uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
                
                // set the pixels to gray in your rect
                
                rgbaPixel[RED] = gray;
                rgbaPixel[GREEN] = gray;
                rgbaPixel[BLUE] = gray;
            }
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

/** Not used at the moment. **/

+(UIImage *)screenshot:(CGRect)cropRect withWindowLayer:(CALayer*)layer
{
    UIGraphicsBeginImageContext(cropRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, -cropRect.origin.x, -cropRect.origin.y - [[UIApplication sharedApplication] statusBarFrame].size.height);
    [layer renderInContext:ctx];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}




-(UIImage*)resizeImage:(UIImage*)image
{
    if(image.size.height <= 300 || image.size.width <=300)
    {
        return image;
    }
    
    //    [self resizeImage:image WithSize:CGRectMake(0, 0, image.size.width, <#CGFloat height#>)
    return nil;
}

-(UIImage*)rectImage:(UIImage*)largeImage withRect:(CGRect)cropRect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([largeImage CGImage], cropRect);
    // or use the UIImage wherever you like
    //UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef scale:largeImage.scale orientation:largeImage.imageOrientation];
    
    //[UIImageView setImage:[UIImage imageWithCGImage:imageRef]];
    CGImageRelease(imageRef);
    
    return finalImage;
}





-(float)calculateCenterX:(float)imageWidth
{
    if(imageWidth <= 300)
    {
        return 0;
    }
    
    return ((imageWidth-300)/2);
}


- (UIImage*)blur:(UIImage*)theImage
{
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];

    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];

    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];

    return [UIImage imageWithCGImage:cgImage];

    // if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}

@end
