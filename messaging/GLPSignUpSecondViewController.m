//
//  GLPSignUpSecondViewController.m
//  Gleepost
//
//  Created by Silouanos on 24/03/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPSignUpSecondViewController.h"
#import "UINavigationBar+Utils.h"
#import "ImageSelectorViewController.h"


@interface GLPSignUpSecondViewController() <ImageSelectorViewControllerDelegate>



@end

@implementation GLPSignUpSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)configureNavigationBar
{
    [super configureNavigationBar];
    [self.navigationController.navigationBar setTextButton:kRight withTitle:@"DONE" withButtonSize:CGSizeMake(60.0, 17.0) withColour:[UIColor whiteColor] withSelector:@selector(signUp:) andTarget:self];
}

#pragma mark - Selectors

- (void)signUp:(id)sender
{
    DDLogDebug(@"GLPSignUpSecondViewController : sign up");
}

- (IBAction)selectImage:(id)sender
{
    [self performSegueWithIdentifier:@"pick image" sender:self];
}

#pragma mark - ImageSelectorViewControllerDelegate 

- (void)takeImage:(UIImage *)image
{
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"pick image"])
    {
        ImageSelectorViewController *imgSelectorVC = segue.destinationViewController;
        imgSelectorVC.fromGroupViewController = NO;
        [imgSelectorVC setDelegate:self];
    }
}

@end
