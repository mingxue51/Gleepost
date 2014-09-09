//
//  ImageSelectorViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 17/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPImageSelectorLoader.h"

@protocol ImageSelectorViewControllerDelegate <NSObject>

@required
- (void)takeImage:(UIImage *)image;

@end

@interface ImageSelectorViewController : UIViewController <GLPImageSelectorLoaderDelegate>

@property (weak, nonatomic) UIViewController <ImageSelectorViewControllerDelegate> *delegate;

@end
