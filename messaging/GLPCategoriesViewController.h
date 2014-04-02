//
//  GLPCategoriesViewController.h
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPTimelineViewController.h"

@interface GLPCategoriesViewController : UIViewController <UINavigationControllerDelegate>

@property (weak, nonatomic) GLPTimelineViewController *delegate;
@property (strong, nonatomic) UIImage *screenshot;
//@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *blurBack;

-(void)setImageToTopImage:(UIImage *)image;

@end
