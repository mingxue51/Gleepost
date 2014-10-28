//
//  GLPPopUpDialogViewController.m
//  Gleepost
//
//  Created by Silouanos on 14/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class is super class for all custom pop-ups.
//

#import "GLPAttendingPopUpViewController.h"
#import "GLPPost.h"

@interface GLPAttendingPopUpViewController ()


@end

@implementation GLPAttendingPopUpViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureDataInElements];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Configurations

- (void)configureDataInElements
{
    [super setTitleWithText:@"Creat!\nYou're now on the g-list!"];
}

//- (void)configureGestures
//{
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView:)];
//    
//    [self.view addGestureRecognizer:tapGesture];
//}
//
//- (void)configureElements
//{
//    _centralView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
//    
//    [_topImageView setImage:_postImage];
//}
//
//- (void)formatView
//{
//    [ShapeFormatterHelper setCornerRadiusWithView:_centralView andValue:4];
//    
//    [ShapeFormatterHelper setTopCornerRadius:_topImageView withViewFrame:_topImageView.frame withValue:4];
//    
//    [ShapeFormatterHelper setTopCornerRadius:_overlayTopImageView withViewFrame:_overlayTopImageView.frame withValue:4];
//}
//
//- (void)animateCentralView
//{
//    [UIView animateWithDuration:0.3/1.5 animations:^{
//        _centralView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.3/2 animations:^{
//            _centralView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.3/2 animations:^{
//                _centralView.transform = CGAffineTransformIdentity;
//            }];
//        }];
//    }];
//}

#pragma mark - Modifiers

- (void)setEventPost:(GLPPost *)eventPost
{
    UIImage *topImage = eventPost.finalImage ? eventPost.finalImage : eventPost.tempImage;
    
    //Detach the a thread if the delay is not satisfiable.
    
    if(!topImage)
    {
        return;
    }
    
    [super setTopImage:topImage];
//    _postImage = [self blurImage:topImage];
    
//    [NSThread detachNewThreadSelector:@selector(blurImage:) toTarget:self withObject:topImage];
}

#pragma mark - Selectors

//- (IBAction)dismissView:(id)sender
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (IBAction)navigateToAttendeesList:(id)sender
{
    [_delegate showAttendees];
    [super dismissView:nil];
}

- (IBAction)addEventToCalendar:(id)sender
{
    [_delegate addEventToCalendar];
    
    [self dismissView:nil];
}

//#pragma mark - Editors
//
//- (UIImage *)blurImage:(UIImage *)image
//{
//    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
//    
//    GPUImageGaussianSelectiveBlurFilter *stillImageFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
//    
//    [stillImageSource addTarget:stillImageFilter];
//    stillImageFilter.excludeBlurSize = 0.0;
//    stillImageFilter.excludeCircleRadius = 0.0;
//    stillImageFilter.excludeCirclePoint = CGPointMake(0.0, 0.0);
//    [stillImageFilter useNextFrameForImageCapture];
//    [stillImageSource processImage];
//
//    
//    UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
//    
//    _postImage = currentFilteredVideoFrame;
//    
//    [_topImageView setImage:_postImage];
//
//    
//    return currentFilteredVideoFrame;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
