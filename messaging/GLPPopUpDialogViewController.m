//
//  GLPPopUpDialogViewController.m
//  Gleepost
//
//  Created by Silouanos on 27/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPopUpDialogViewController.h"
#import "GPUImage.h"
#import "ShapeFormatterHelper.h"

@interface GLPPopUpDialogViewController ()

@property (strong, nonatomic) UIImage *topImage;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation GLPPopUpDialogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureElements];
    
    [self configureGestures];
    
    [self formatView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self animateCentralView];
}

- (void)configureGestures
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView:)];
    
    [self.view addGestureRecognizer:tapGesture];
}

- (void)configureElements
{
    _centralView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    
    [_topImageView setImage:_topImage];
}

- (void)formatView
{
    [ShapeFormatterHelper setCornerRadiusWithView:_centralView andValue:4];
    
    [ShapeFormatterHelper setTopCornerRadius:_topImageView withViewFrame:_topImageView.frame withValue:4];
    
    [ShapeFormatterHelper setTopCornerRadius:_overlayTopImageView withViewFrame:_overlayTopImageView.frame withValue:4];
}

- (void)animateCentralView
{
    [UIView animateWithDuration:0.3/1.5 animations:^{
        _centralView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            _centralView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                _centralView.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

#pragma mark - Modifiers

- (void)setTopImage:(UIImage *)image
{
    _topImage = [self blurImage:image];
}

- (void)setTitleWithText:(NSString *)title
{
    [_messageLabel setText:title];
}

#pragma mark - Selectors

- (IBAction)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Editors

- (UIImage *)blurImage:(UIImage *)image
{
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
    
    GPUImageGaussianSelectiveBlurFilter *stillImageFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
    
    [stillImageSource addTarget:stillImageFilter];
    stillImageFilter.excludeBlurSize = 0.0;
    stillImageFilter.excludeCircleRadius = 0.0;
    stillImageFilter.excludeCirclePoint = CGPointMake(0.0, 0.0);
    [stillImageFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
    
    
    UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
    
    _topImage = currentFilteredVideoFrame;
    
    [_topImageView setImage:_topImage];
    
    
    return currentFilteredVideoFrame;
}

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
