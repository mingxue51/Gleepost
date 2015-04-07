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
#import "FakeNavigationBarNewPostView.h"
#import "GLPIntroNewPostAnimationHelper.h"

@interface IntroKindOfNewPostViewController () <UINavigationControllerDelegate, GLPIntroNewPostAnimationHelperDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstrain;

//Distances constraints.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pencilDistanceFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleDistanceFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *announcementDistanceFromBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generalDistanceFromBottom;

//Views.
@property (weak, nonatomic) IBOutlet UIButton *nevermindButton;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *elements;


@property (strong, nonatomic) TDNavigationNewPost *tdNavigationNewPost;
@property (strong, nonatomic) FakeNavigationBarNewPostView *fakeNavigationBar;
@property (strong, nonatomic) GLPIntroNewPostAnimationHelper *animationsHelper;

@property (assign, nonatomic) BOOL readToGoToNextView;

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
    [self initialisePositions];
    
    //http://stackoverflow.com/questions/26569488/navigation-controller-custom-transition-animation
    self.navigationController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
    [self animateElementsAfterViewDidLoad];
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
    self.animationsHelper = [[GLPIntroNewPostAnimationHelper alloc] init];
    self.animationsHelper.delegate = self;
    self.readToGoToNextView = NO;
}

- (void)initialisePositions
{
    self.announcementDistanceFromBottom.constant = -[self.animationsHelper getInitialElementsPosition];
    self.generalDistanceFromBottom.constant = -[self.animationsHelper getInitialElementsPosition];
    self.pencilDistanceFromTop.constant = [self.animationsHelper getInitialElementsPosition];
    self.titleDistanceFromTop.constant = [self.animationsHelper getInitialElementsPosition];
}

- (void)dealloc
{    
    [[PendingPostManager sharedInstance] reset];
}

- (void)configureNavigationBar
{
//    self.title = @"NEW POST";
    
    [self.navigationController.navigationBar invisible];
    
    self.fakeNavigationBar = [[FakeNavigationBarNewPostView alloc] init];
    [self.view addSubview:self.fakeNavigationBar];
    
    [self.navigationController.navigationBar setButton:kLeft specialButton:kQuit withImageName:@"cancel" withButtonSize:CGSizeMake(19.0, 21.0) withSelector:@selector(dismiss:) andTarget:self];
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

#pragma mark - Animations

- (void)animateElementsAfterViewDidLoad
{
    [self.animationsHelper viewDidLoadAnimationWithConstraint:self.announcementDistanceFromBottom andKindOfElement:kAnnouncementElement];
    [self.animationsHelper viewDidLoadAnimationWithConstraint:self.generalDistanceFromBottom andKindOfElement:kGeneralElement];
    [self.animationsHelper viewDidLoadAnimationWithConstraint:self.pencilDistanceFromTop andKindOfElement:kPencilElement];
    [self.animationsHelper viewDidLoadAnimationWithConstraint:self.titleDistanceFromTop andKindOfElement:kTitleElement];
    [self.animationsHelper animateNevermindView:self.nevermindButton withAppearance:YES];
}

- (void)animateElementsBeforeDisappearing
{
    for(UIView *view in self.elements)
    {
        [self.animationsHelper viewDisappearingAnimationWithView:view andKindOfElement:view.tag];
    }
}

#pragma mark - GLPIntroNewPostAnimationHelperDelegate

- (void)viewsDisappeared
{
    if(self.readToGoToNextView)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"new_post" bundle:nil];
        IntroKindOfEventViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"IntroKindOfEventViewController"];
        [self.navigationController pushViewController:cvc animated:NO];
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
    
    [self animateElementsBeforeDisappearing];
    
    self.readToGoToNextView = YES;

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
