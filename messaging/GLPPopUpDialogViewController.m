//
//  GLPPopUpDialogViewController.m
//  Gleepost
//
//  Created by Silouanos on 14/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPopUpDialogViewController.h"
#import "UIImage+StackBlur.h"

@interface GLPPopUpDialogViewController ()

@property (weak, nonatomic) IBOutlet UIView *centralView;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;

@property (strong, nonatomic) UIImage *postImage;

@end

@implementation GLPPopUpDialogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureElements];
    
    
    [self configureGestures];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self animateCentralView];

}

#pragma mark - Configurations

- (void)configureGestures
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView:)];
    
    [self.view addGestureRecognizer:tapGesture];
}

- (void)configureElements
{
    _centralView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    
    [_topImageView setImage:_postImage];
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

- (void)setTopImage:(UIImage *)topImage
{
    UIImage *image = topImage;
    _postImage = [image stackBlur:10.0f];
}

#pragma mark - Selectors

- (IBAction)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)navigateToAttendeesList:(id)sender
{
    [_delegate showAttendees];
}

- (IBAction)addEventToCalendar:(id)sender
{
    [_delegate addEventToCalendar];
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
