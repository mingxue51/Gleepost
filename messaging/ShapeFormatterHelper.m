//
//  ShapeFormatterHelper.m
//  Gleepost
//
//  Created by Σιλουανός on 5/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ShapeFormatterHelper.h"
#import "AppearanceHelper.h"
#import "GLPiOSSupportHelper.h"

@implementation ShapeFormatterHelper


+(void)setRoundedView:(UIView *)roundedView toDiameter:(CGFloat)newSize
{
    roundedView.clipsToBounds = YES;
    
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}

+ (void)setRoundedViewWithNotClipToBounds:(UIView *)roundedView toDiameter:(float)newSize
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}

/**
 Converts the two top corners of an image view from straight to circles.
 
 @param imageView the incoming image view.
 @param viewBounds the bounds of the parent view.
 @param sizeOfCorners the size of the new corners.
 
 */
+(void)createTwoTopCornerRadius:(UIImageView*)imageView withViewBounts:(CGRect)viewBounds andSizeOfCorners:(CGSize)sizeOfCorners
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:viewBounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:sizeOfCorners];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = viewBounds;
    maskLayer.path = maskPath.CGPath;
    imageView.layer.mask = maskLayer;
}

+(void)setTwoLeftCornerRadius:(UIImageView *)imageView withViewFrame:(CGRect)frame withValue:(int)value
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(value, value)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = frame;
    maskLayer.path = maskPath.CGPath;
    imageView.layer.mask = maskLayer;
}

+(void)setTwoBottomCornerRadius:(UIView *)view withViewFrame:(CGRect)frame withValue:(int)value
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(value, value)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = frame;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

+(void)setTopCornerRadius:(UIView *)view withViewFrame:(CGRect)frame withValue:(int)value
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(value, value)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = frame;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

+ (void)removeBottomCornerRadius:(UIView *)view
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(0.0, 0.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

+(void)setCornerRadiusWithView:(UIView *)imageView andValue:(int)value
{
    imageView.layer.cornerRadius = value;
}

+(void)setElement:(UIView *)element withExtraHeight:(float)height
{    
    CGRect frame = element.frame;
    
    [element setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height)];
}

+(void)setElement:(UIView *)element withExtraY:(float)y
{
    CGRect frame = element.frame;
    
    [element setFrame:CGRectMake(frame.origin.x, y, frame.size.width, frame.size.height)];
}

+(void)setBorderToView:(UIView *)view withColour:(UIColor *)colour andWidth:(float)width
{
    [view.layer setBorderColor:colour.CGColor];
    [view.layer setBorderWidth:width];
}

+ (void)resetAnyFormatOnView:(UIView *)view
{
    view.layer.mask = nil;
    view.layer.sublayers  = nil;
    view.layer.cornerRadius = 0.0;
    view.layer.borderWidth = 0.0;
}

+ (void)setBottomCornerRadius:(UIImageView *)imageView withValue:(float)value
{
    // set the radius
    CGFloat radius = value;
    
    // set the mask frame, and change the y value by the
    // corner radius to hide top corners
    CGRect maskFrame = imageView.bounds;
    maskFrame.origin.y -= value;
    
    // create the mask layer
    CALayer *maskLayer = [CALayer layer];
    maskLayer.cornerRadius = radius;
    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    maskLayer.frame = maskFrame;
    
    // set the mask
    imageView.layer.mask = maskLayer;
}

/**
 Method used for test purposes.
 
 @param view
 @param colour
 */
+(void)setBorderToView:(UIView *)view withColour:(UIColor *)colour
{
    [view.layer setBorderColor:colour.CGColor];
    [view.layer setBorderWidth:2.0f];
}

#pragma mark - Comment cell

+ (void)formatTopCellWithBackgroundView:(UIImageView *)backgroundView andSuperView:(UIView *)superview
{
    [backgroundView layoutIfNeeded];
    
    CGRect bounds = backgroundView.bounds;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                                         cornerRadii:CGSizeMake(3.0, 3.0)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    backgroundView.layer.mask = maskLayer;
    
    CAShapeLayer*   frameLayer = [CAShapeLayer layer];
    frameLayer.frame = bounds;
    frameLayer.path = maskPath.CGPath;
    frameLayer.strokeColor = [AppearanceHelper mediumGrayGleepostColour].CGColor;
    frameLayer.fillColor = nil;
    frameLayer.lineWidth = 2.0;
    
    [backgroundView.layer addSublayer:frameLayer];
    
    
//    CALayer *bottomBorder = [CALayer layer];
//    bottomBorder.borderColor = [UIColor whiteColor].CGColor;
//    bottomBorder.borderWidth = 4;
//    bottomBorder.frame = CGRectMake(11.0f, backgroundView.frame.size.height - 2, [GLPiOSSupportHelper screenWidth] - 22, 4.0);
//    
//    [superview.layer addSublayer:bottomBorder];
    
    UIImageView *bottomBorder = [[UIImageView alloc] initWithFrame:CGRectMake(11.0f, backgroundView.frame.size.height - 2, [GLPiOSSupportHelper screenWidth] - 22, 2.0)];
    bottomBorder.tag = 100;
    [bottomBorder setBackgroundColor:[UIColor whiteColor]];
    [superview addSubview:bottomBorder];
}

+ (void)formatBottomCellWithBackgroundView:(UIImageView *)backgroundImageView andSuperView:(UIView *)superview
{
    [backgroundImageView layoutIfNeeded];
    
    CGRect bounds = backgroundImageView.bounds;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                                         cornerRadii:CGSizeMake(3.0, 3.0)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    backgroundImageView.layer.mask = maskLayer;
    
//    CAShapeLayer*   frameLayer = [CAShapeLayer layer];
//    frameLayer.frame = bounds;
//    frameLayer.path = maskPath.CGPath;
//    frameLayer.strokeColor = [AppearanceHelper mediumGrayGleepostColour].CGColor;
//    frameLayer.fillColor = nil;
//    frameLayer.lineWidth = 2.0;
//    
//    [backgroundImageView.layer addSublayer:frameLayer];
    
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[AppearanceHelper mediumGrayGleepostColour] CGColor];
    upperBorder.frame = CGRectMake(0, bounds.size.height - 1, CGRectGetWidth(bounds), 1.0f);
    [backgroundImageView.layer addSublayer:upperBorder];
    
    upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[AppearanceHelper mediumGrayGleepostColour] CGColor];
    upperBorder.frame = CGRectMake(CGRectGetWidth(bounds) - 1, 0.0, 1.0f, CGRectGetHeight(bounds));
    [backgroundImageView.layer addSublayer:upperBorder];
    
    upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[AppearanceHelper mediumGrayGleepostColour] CGColor];
    upperBorder.frame = CGRectMake(0, 0, 1.0f, CGRectGetHeight(bounds));
    [backgroundImageView.layer addSublayer:upperBorder];
    

    
//    CALayer *bottomBorder = [CALayer layer];
//    bottomBorder.borderColor = [UIColor whiteColor].CGColor;
//    bottomBorder.borderWidth = 1;
//    bottomBorder.frame = CGRectMake(11.0f, 0.0, [GLPiOSSupportHelper screenWidth] - 22, 1.0);
//    
//    [superview.layer addSublayer:bottomBorder];
}

/**
 This method should be called only for every cell that is not top cell
 so can remove the bottom line that is reused when is added in top cell
 configuration.
 */
+ (void)removeTopCellBottomLine:(UIView *)superview
{
    for(UIView *view in superview.subviews)
    {
        if(view.tag == 100)
        {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Helpers

static inline UIImage* MTDContextCreateRoundedMask(CGRect rect, CGFloat radius_tl, CGFloat radius_tr, CGFloat radius_bl, CGFloat radius_br) {
    
    CGContextRef context;
    CGColorSpaceRef colorSpace;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a bitmap graphics context the size of the image
    context = CGBitmapContextCreate( NULL, rect.size.width, rect.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast );
    
    // free the rgb colorspace
    CGColorSpaceRelease(colorSpace);
    
    if ( context == NULL ) {
        return NULL;
    }
    
    // cerate mask
    
    CGFloat minx = CGRectGetMinX( rect ), midx = CGRectGetMidX( rect ), maxx = CGRectGetMaxX( rect );
    CGFloat miny = CGRectGetMinY( rect ), midy = CGRectGetMidY( rect ), maxy = CGRectGetMaxY( rect );
    
    CGContextBeginPath( context );
    CGContextSetGrayFillColor( context, 1.0, 0.0 );
    CGContextAddRect( context, rect );
    CGContextClosePath( context );
    CGContextDrawPath( context, kCGPathFill );
    
    CGContextSetGrayFillColor( context, 1.0, 1.0 );
    CGContextBeginPath( context );
    CGContextMoveToPoint( context, minx, midy );
    CGContextAddArcToPoint( context, minx, miny, midx, miny, radius_bl );
    CGContextAddArcToPoint( context, maxx, miny, maxx, midy, radius_br );
    CGContextAddArcToPoint( context, maxx, maxy, midx, maxy, radius_tr );
    CGContextAddArcToPoint( context, minx, maxy, minx, midy, radius_tl );
    CGContextClosePath( context );
    CGContextDrawPath( context, kCGPathFill );
    
    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef bitmapContext = CGBitmapContextCreateImage( context );
    CGContextRelease( context );
    
    // convert the finished resized image to a UIImage
    UIImage *theImage = [UIImage imageWithCGImage:bitmapContext];
    // image is retained by the property setting above, so we can
    // release the original
    CGImageRelease(bitmapContext);
    
    // return the image
    return theImage;
}

@end
