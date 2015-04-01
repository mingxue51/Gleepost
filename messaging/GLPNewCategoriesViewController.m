//
//  GLPNewCategoriesViewController.m
//  Gleepost
//
//  Created by Silouanos on 01/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPNewCategoriesViewController.h"
#import "UIImage+StackBlur.h"
#import "GPUImage.h"
#import <POP/POP.h>

@interface GLPNewCategoriesViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *allPostsView;

//Constraints.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceAllPostsViewFromTop;

@end

@implementation GLPNewCategoriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.allPostsView layoutIfNeeded];
    
    self.distanceAllPostsViewFromTop.constant = -(self.distanceAllPostsViewFromTop.constant + self.allPostsView.frame.size.height);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self animateAllPostsView];
    
}

#pragma mark - Animations

- (void)animateAllPostsView
{
    // 1. Pick a Kind Of Animation //  POPBasicAnimation  POPSpringAnimation POPDecayAnimation
    POPSpringAnimation *basicAnimation = [POPSpringAnimation animation];
    
    // 2. Decide weather you will animate a view property or layer property, Lets pick a View Property and pick kPOPViewFrame
    // View Properties - kPOPViewAlpha kPOPViewBackgroundColor kPOPViewBounds kPOPViewCenter kPOPViewFrame kPOPViewScaleXY kPOPViewSize
    // Layer Properties - kPOPLayerBackgroundColor kPOPLayerBounds kPOPLayerScaleXY kPOPLayerSize kPOPLayerOpacity kPOPLayerPosition kPOPLayerPositionX kPOPLayerPositionY kPOPLayerRotation kPOPLayerBackgroundColor
    basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    
    // 3. Figure Out which of 3 ways to set toValue
    basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayoutConstraintConstant];
    basicAnimation.toValue = @(80.0);
    basicAnimation.springSpeed = 10.0f;
    basicAnimation.springBounciness = 10.0f;
    
    // 4. Create Name For Animation & Set Delegate
    basicAnimation.name=@"AnyAnimationNameYouWant";
    basicAnimation.delegate=self;
    
    // 5. Add animation to View or Layer, we picked View so self.tableView and not layer which would have been self.tableView.layer
    [self.distanceAllPostsViewFromTop pop_addAnimation:basicAnimation forKey:@"WhatEverNameYouWant"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Image

- (void)setCampusWallScreenshot:(UIImage *)campusWallImage
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:campusWallImage];
        
        GPUImageGaussianSelectiveBlurFilter *stillImageFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
        
        [stillImageSource addTarget:stillImageFilter];
        stillImageFilter.excludeBlurSize = 0.0;
        stillImageFilter.excludeCircleRadius = 0.0;
        stillImageFilter.excludeCirclePoint = CGPointMake(0.0, 0.0);
        [stillImageFilter useNextFrameForImageCapture];
        [stillImageSource processImage];
        
        UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.backgroundImageView setImage:currentFilteredVideoFrame];
        });
    });
    
}

#pragma mark - Selectors

- (IBAction)hideViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
