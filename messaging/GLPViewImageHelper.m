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
#import "UIColor+GLPAdditions.h"

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
    
    imagePickerController = [self configureInitialActionsWithImagePicker:imagePickerController];
    imagePickerController = [self configureSecondaryActionsWithImagePicker:imagePickerController];
    
    return imagePickerController;
}

+ (ImagePickerSheetController *)configureInitialActionsWithImagePicker:(ImagePickerSheetController *)imagePicker
{
    [imagePicker addInitialAction:[[GLPMultipleImagesAction alloc] initWithImagesNames:@[@"test", @"test2", @"test3"]]];
    
    [imagePicker addInitialAction:[[GLPImageDefaultImageAction alloc] initWithTitle:@"Select a location" imageName:@"pick_location" textColour:[UIColor colorWithR:34.0 withG:218.0 andB:160.0]]];
    
    [imagePicker addInitialAction:[[GLPDefaultImageAction alloc] initWithTitle:@"Cancel" textColour:[UIColor colorWithR:167.0 withG:167.0 andB:167.0]]];
    
    return imagePicker;
}

+ (ImagePickerSheetController *)configureSecondaryActionsWithImagePicker:(ImagePickerSheetController *)imagePicker
{
    [imagePicker addSecondaryAction:[[GLPDefaultImageAction alloc] initWithTitle:@"Send 1 image" textColour:[UIColor colorWithR:34.0 withG:218.0 andB:160.0]]];
    
    [imagePicker addSecondaryAction:[[GLPImageDefaultImageAction alloc] initWithTitle:@"back to options"imageName:@"back_to_pick_image" textColour:[UIColor colorWithR:167 withG:167 andB:167]]];
    
    [imagePicker addSecondaryAction:[[GLPDefaultImageAction alloc] initWithTitle:@"Cancel" textColour:[UIColor colorWithR:167.0 withG:167.0 andB:167.0]]];
    
    return imagePicker;
}

@end