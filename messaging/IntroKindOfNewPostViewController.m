//
//  IntroKindOfNewPostViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 14/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "IntroKindOfNewPostViewController.h"
#import "PendingPostManager.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "PendingPostManager.h"
#import "AppearanceHelper.h"
#import "GLPApprovalManager.h"
#import "GLPiOSSupportHelper.h"
#import "TDNavigationNewPost.h"
#import "ATNavigationNewPost.h"
#import "IntroKindOfEventViewController.h"

@interface IntroKindOfNewPostViewController () <UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstrain;
@property (strong, nonatomic) TDNavigationNewPost *tdNavigationNewPost;

@end

@implementation IntroKindOfNewPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
    
    [self configureIsGroupPost];
    
    [[GLPApprovalManager sharedInstance] reloadApprovalLevel];
    
    [self configureConstrainsDependingOnScreenSize];
    
    [self intialiseObjects];
    
    //http://stackoverflow.com/questions/26569488/navigation-controller-custom-transition-animation
    self.navigationController.delegate = self;
}

//- (void)viewDidDisappear:(BOOL)animated
//{
//    [[PendingPostManager sharedInstance] reset];
//    
//    [super viewDidDisappear:animated];
//}

- (void)intialiseObjects
{
    self.tdNavigationNewPost = [[TDNavigationNewPost alloc] init];
}

- (void)dealloc
{    
    [[PendingPostManager sharedInstance] reset];
}

- (void)configureNavigationBar
{
    self.title = @"NEW POST";
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    
    [self.navigationController.navigationBar setButton:kLeft specialButton:kQuit withImageName:@"cancel" withButtonSize:CGSizeMake(19.0, 21.0) withSelector:@selector(dismiss:) andTarget:self];
    
    self.navigationController.navigationBar.tintColor = [AppearanceHelper blueGleepostColour];

}

- (void)configureIsGroupPost
{
    [[PendingPostManager sharedInstance] setGroupPost:self.groupPost];
    [[PendingPostManager sharedInstance] setGroup:self.group];
}

- (void)configureConstrainsDependingOnScreenSize
{
    if([GLPiOSSupportHelper useShortConstrains])
    {
        [_titleHeightConstrain setConstant:-60];
    }
}

#pragma mark - Selectors

- (IBAction)selectEvent:(id)sender
{
    if([[PendingPostManager sharedInstance] kindOfPost] != kEventPost)
    {
        [[PendingPostManager sharedInstance] reset];
    }
    
    [[PendingPostManager sharedInstance] setGroup:_group];
    
    [[PendingPostManager sharedInstance] setGroupPost:_groupPost];
    
    
    [[PendingPostManager sharedInstance] setKindOfPost:kEventPost];
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"new_post" bundle:nil];
    IntroKindOfEventViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"IntroKindOfEventViewController"];
    
    [self.navigationController pushViewController:cvc animated:NO];

//    cvc.modalPresentationStyle = UIModalPresentationCustom;
    
//    [cvc setTransitioningDelegate:self.tdNavigationNewPost];
    
    
//    [self presentViewController:cvc animated:YES completion:nil];
    
//    [self performSegueWithIdentifier:@"view event selector" sender:self];
}

- (IBAction)selectAnnouncement:(id)sender
{
    //TODO: Change that when announcements are ready to be implemented.
    [self selectGeneral:sender];
    
//    if([[PendingPostManager sharedInstance] kindOfPost] != kAnnouncementPost)
//    {
//        [[PendingPostManager sharedInstance] reset];
//    }
//    
//    [[PendingPostManager sharedInstance] setGroup:_group];
//    
//    [[PendingPostManager sharedInstance] setGroupPost:_groupPost];
//    
//    [[PendingPostManager sharedInstance] setKindOfPost:kAnnouncementPost];
//    
//    [self performSegueWithIdentifier:@"final new post" sender:self];

}

- (IBAction)selectGeneral:(id)sender
{
    DDLogDebug(@"Parent view contoller: %@ : %d", _group, _groupPost);
    
    if([[PendingPostManager sharedInstance] kindOfPost] != kGeneralPost)
    {
        [[PendingPostManager sharedInstance] reset];
    }
    
    [[PendingPostManager sharedInstance] setGroup:_group];
    
    [[PendingPostManager sharedInstance] setGroupPost:_groupPost];
    
    [[PendingPostManager sharedInstance] setKindOfPost:kGeneralPost];
    
    [self performSegueWithIdentifier:@"final new post" sender:self];
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    if (operation == UINavigationControllerOperationPush)
        return [[ATNavigationNewPost alloc] init];
    
    if (operation == UINavigationControllerOperationPop)
        return [[ATNavigationNewPost alloc] init];
    
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
