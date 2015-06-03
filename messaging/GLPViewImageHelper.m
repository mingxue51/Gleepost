//
//  GLPViewImageHelper.m
//  Gleepost
//
//  Created by Silouanos on 19/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Helper that includes image operations:
//  Shows an image in a view controller.
//  Presents an iOS 8 image picker.
//  To be extended for further operations.

#import "GLPViewImageHelper.h"
#import "JTSImageViewController.h"
#import <Photos/Photos.h>
#import "NerdNation-Swift.h"

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

+ (ImagePickerSheetController *)generateImagePickerForChat
{
//    [PHPhotoLibrary authorizationStatus];
    
    ImagePickerSheetController *imagePickerController = [[ImagePickerSheetController alloc] init];
    
    [imagePickerController addAction:[[GLPImageDefaultImageAction alloc] initWithTitle:@"Select a location" secondaryTitle:@"Select a location" imageName:@"pick_location"]];
    
    [imagePickerController addAction:[[GLPDefaultImageAction alloc] initWithTitle:@"Cancel" secondaryTitle:@"Cancel"]];
    
    return imagePickerController;
    
}

@end