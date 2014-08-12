//
//  ShapeFormatterHelper.m
//  Gleepost
//
//  Created by Σιλουανός on 5/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ShapeFormatterHelper.h"

@implementation ShapeFormatterHelper


+(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize
{
    roundedView.clipsToBounds = YES;
    
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
    maskPath = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:sizeOfCorners];
    
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

+(void)setCornerRadiusWithView:(UIView*)imageView andValue:(int)value
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

+ (void)setBottomExCornerRadius:(UIImageView *)theView withValue:(float)value
{
    // Create the mask image you need calling the previous function
    UIImage *theImage = MTDContextCreateRoundedMask(theView.bounds, 30, 30, 0.0, 0.0 );
    
//    [imageView setImage:mask];
    
    // Create the path (with only the top-left corner rounded)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:theView.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft
                                                         cornerRadii:CGSizeMake(10.0f, 10.0f)];
    
    // Create the shadow layer
    CAShapeLayer *shadowLayer = [CAShapeLayer layer];
    [shadowLayer setFrame:theView.bounds];
    [shadowLayer setMasksToBounds:NO];
    [shadowLayer setShadowPath:maskPath.CGPath];
    // ...
    // Set the shadowColor, shadowOffset, shadowOpacity & shadowRadius as required
    // ...
    
    // Create the rounded layer, and mask it using the rounded mask layer
    CALayer *roundedLayer = [CALayer layer];
    [roundedLayer setFrame:theView.bounds];
    [roundedLayer setContents:(id)theImage.CGImage];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    [maskLayer setFrame:theView.bounds];
    [maskLayer setPath:maskPath.CGPath];
    
    roundedLayer.mask = maskLayer;
    
    // Add these two layers as sublayers to the view
//    [theView.layer addSublayer:shadowLayer];
    [theView.layer addSublayer:roundedLayer];
    
//    // Create a new layer that will work as a mask
//    CALayer *layerMask = [CALayer layer];
//    layerMask.frame = imageView.bounds;
//    // Put the mask image as content of the layer
//    layerMask.contents = (id)mask.CGImage;
//    // set the mask layer as mask of the view layer
//    imageView.layer.mask = layerMask;
    
//    // Add a backaground color just to check if it works
//    imageView.backgroundColor = [UIColor redColor];
//    // Add a test view to verify the correct mask clipping
//    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake( 0.0, 0.0, 50.0, 50.0 )];
//    testView.backgroundColor = [UIColor blueColor];
//    [imageView addSubview:testView];
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

+ (void)setBorderToView:(UIView *)view inLine:(UIRectEdge)edge withColour:(UIColor *)colour andWidth:(float)width
{
    if(edge == UIRectEdgeBottom)
    {
        // Add a bottomBorder.
        CALayer *bottomBorder = [CALayer layer];
        
        bottomBorder.frame = CGRectMake(0.0f, view.frame.size.height - 1, view.frame.size.width, 1.0f);
        
        bottomBorder.backgroundColor = colour.CGColor;
        
        [view.layer addSublayer:bottomBorder];
    }
}


static inline UIImage* MTDContextCreateRoundedMask( CGRect rect, CGFloat radius_tl, CGFloat radius_tr, CGFloat radius_bl, CGFloat radius_br ) {
    
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
