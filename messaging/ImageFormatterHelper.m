//
//  ImageFormatterHelper.m
//  Gleepost
//
//  Created by Σιλουανός on 11/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ImageFormatterHelper.h"

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

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
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
