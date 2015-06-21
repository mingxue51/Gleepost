//
//  GLPViewImageHelper.h
//  Gleepost
//
//  Created by Silouanos on 19/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImagePickerSheetController;

@interface GLPViewImageHelper : NSObject

+ (void)showImageInViewController:(UIViewController *)viewController withImageView:(UIImageView *)imageView;
+ (ImagePickerSheetController *)generateImagePickerForChat;

@end
