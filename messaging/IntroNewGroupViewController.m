//
//  IntroNewGroupViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 15/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "IntroNewGroupViewController.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "ShapeFormatterHelper.h"
#import "UIView+GLPDesign.h"
#import "GLPiOSSupportHelper.h"

@interface IntroNewGroupViewController ()

@property IBOutlet UIView *publicGroupView;
@property IBOutlet UIView *privateGroupView;
@property IBOutlet UIView *secretGroupView;

@property (assign, nonatomic) GroupPrivacy currentGroupPrivacy;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDistanceFromTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomDistanceFromTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceBetweenFirstAndSecond;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceBetweenSecondAndThird;


@end

@implementation IntroNewGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configNavigationBar];
    [self configureViewsGestures];
    [self formatViews];
    [self configureViews];
}

- (void)configNavigationBar
{
    //Change the format of the navigation bar.
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
    
    [self.navigationController.navigationBar setButton:kLeft specialButton:kQuit withImageName:@"cancel" withButtonSize:CGSizeMake(19.0, 21.0) withSelector:@selector(dismissModalView) andTarget:self];

    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)configureViewsGestures
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPublicGroup)];
    [tap setNumberOfTapsRequired:1];
    [_publicGroupView addGestureRecognizer:tap];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPrivateGroup)];
    [tap setNumberOfTapsRequired:1];
    [_privateGroupView addGestureRecognizer:tap];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectSecretGroup)];
    [tap setNumberOfTapsRequired:1];
    [_secretGroupView addGestureRecognizer:tap];
}

- (void)formatViews
{
    [_privateGroupView setGleepostStyleBorder];
    [_publicGroupView setGleepostStyleBorder];
    [_secretGroupView setGleepostStyleBorder];
}

- (void)configureViews
{
    if([GLPiOSSupportHelper useShortConstrains])
    {
        [_topDistanceFromTitle setConstant:5.0];
        [_bottomDistanceFromTitle setConstant:5.0];
        [_distanceBetweenFirstAndSecond setConstant:5.0];
        [_distanceBetweenSecondAndThird setConstant:5.0];
    }
}

#pragma mark - Selectors

- (void)dismissModalView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectPublicGroup
{
    DDLogDebug(@"Select public group.");
    _currentGroupPrivacy = kPublicGroup;
    [self performSegueWithIdentifier:@"new group" sender:self];

}

- (void)selectPrivateGroup
{
    DDLogDebug(@"Select private group.");
    _currentGroupPrivacy = kPrivateGroup;
    [self performSegueWithIdentifier:@"new group" sender:self];


}

- (void)selectSecretGroup
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone" bundle:nil];
//    GLPSelectCategoryViewController *categoriesVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPSelectCategoryViewController"];
//    [categoriesVC setDelegate:self];
//    categoriesVC.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.67];
//    
//    categoriesVC.modalPresentationStyle = UIModalPresentationCustom;
//    
//    
//    if(![GLPiOS6Helper isIOS6])
//    {
//        [categoriesVC setTransitioningDelegate:_transitionViewCategories];
//    }
//    
//    
//    [self presentViewController:categoriesVC animated:YES completion:nil];
    
//    [[PendingGroupManager sharedInstance] setPrivacy:kSecret];
    
    _currentGroupPrivacy = kSecretGroup;

    [self performSegueWithIdentifier:@"new group" sender:self];
}

#pragma mark - GroupCreatedDelegate

- (void)groupCreatedWithData:(GLPGroup *)group
{
    //Dismiss view controller and send notification to the preview view. (groups view)
        
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"new group"])
    {
        NewGroupViewController *newGroupViewController = segue.destinationViewController;
        
        [newGroupViewController setDelegate:self];
        
        newGroupViewController.groupType = _currentGroupPrivacy;
    }
    
    
}


@end
