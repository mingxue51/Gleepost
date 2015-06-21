//
//  GLPNewCategoriesViewController.h
//  Gleepost
//
//  Created by Silouanos on 01/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GLPCategoriesViewControllerDelegate <NSObject>

@required
- (void)refreshPostsWithNewCategory;

@end

@interface GLPNewCategoriesViewController : UIViewController

@property (weak, nonatomic) UIViewController <GLPCategoriesViewControllerDelegate> *delegate;

- (void)setCampusWallScreenshot:(UIImage *)campusWallImage;

@end
