//
//  GLPViewImageHelper.m
//  Gleepost
//
//  Created by Silouanos on 19/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Helper that shows an image in a view controller. To be extended for further operations.

#import "GLPViewImageHelper.h"
#import "JTSImageViewController.h"

@implementation GLPViewImageHelper

+ (void)showImageInViewController:(UIViewController *)viewController withImageView:(UIImageView *)imageView
{
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = imageView.image;
    imageInfo.referenceRect = imageView.frame;
    imageInfo.referenceView = imageView.superview;
    
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    
    // Present the view controller.
    [imageViewer showFromViewController:viewController transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

@end
