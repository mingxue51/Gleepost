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
#import "NewPostViewController.h"

@interface IntroKindOfNewPostViewController () <UINavigationControllerDelegate, GLPIntroNewPostAnimationHelperDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstrain;

//Distances constraints.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pencilDistanceFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleDistanceFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *announcementDistanceFromBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generalDistanceFromBottom;

//X Constraints.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generalDistanceFromCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionDistanceFromCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventDistanceFromCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *announcementDistanceFromCenter;

//Views.
@property (weak, nonatomic) IBOutlet UIButton *nevermindButton;
@property (weak, nonatomic) IBOutlet UIView *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *pencilView;
@property (weak, nonatomic) IBOutlet UIView *generalView;
@property (weak, nonatomic) IBOutlet UIView *eventView;
@property (weak, nonatomic) IBOutlet UIView *questionView;
@property (weak, nonatomic) IBOutlet UIView *announcementView;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *elements;

//Labels.
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsElements;

@property (strong, nonatomic) TDNavigationNewPost *tdNavigationNewPost;
@property (strong, nonatomic) FakeNavigationBarNewPostView *fakeNavigationBar;
@property (strong, nonatomic) GLPIntroNewPostAnimationHelper *animationsHelper;

@property (assign, nonatomic) BOOL readyToGoToEventsView;
@property (assign, nonatomic) BOOL readyToGoToGeneralView;
@property (assign, nonatomic) BOOL readyToGoToPollView;

@property (assign, nonatomic) BOOL viewDidAppearFirstOccurrence;

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
    
    [self resetReadyToGoBooleans];
    
    if(self.viewDidAppearFirstOccurrence)
    {
        [self animateElementsAfterViewDidLoad];
    }
    else
    {
        [self animateElementsAfterComingBack];
        [self renewAnimationDelaysForElementsForAppearing:NO];
    }
    
    self.viewDidAppearFirstOccurrence = NO;
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
    self.viewDidAppearFirstOccurrence = YES;
}

- (void)resetReadyToGoBooleans
{
    self.readyToGoToEventsView = NO;
    self.readyToGoToGeneralView = NO;
    self.readyToGoToPollView = NO;
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
    [self.fakeNavigationBar selectDotWithNumber:1];
    [self.view addSubview:self.fakeNavigationBar];
    
    [self.navigationController.navigationBar setButton:kLeft specialButton:kQuit withImageName:@"cancel" withButtonSize:CGSizeMake(19.0, 21.0) withSelector:@selector(dismiss:) andTarget:self];
    
    if(self.groupPost)
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
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
        for(UILabel *elementLabel in self.labelsElements)
        {
            [elementLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:12.0]];
        }
    }

}

#pragma mark - Positioning

- (void)initialisePositions
{
    self.announcementDistanceFromBottom.constant = -[self.animationsHelper getInitialElementsPosition];
    self.generalDistanceFromBottom.constant = -[self.animationsHelper getInitialElementsPosition];
    self.pencilDistanceFromTop.constant = [self.animationsHelper getInitialElementsPosition];
    self.titleDistanceFromTop.constant = [self.animationsHelper getInitialElementsPosition];
}

- (void)setPositionsOnElementsAfterGoingForward
{
    [self.animationsHelper setPositionToView:self.eventView afterForwardingWithConstraint:self.eventDistanceFromCenter withMinusSign:NO];
    [self.animationsHelper setPositionToView:self.questionView afterForwardingWithConstraint:self.questionDistanceFromCenter withMinusSign:YES];
    [self.animationsHelper setPositionToView:self.announcementView afterForwardingWithConstraint:self.announcementDistanceFromCenter withMinusSign:NO];
    [self.animationsHelper setPositionToView:self.generalView afterForwardingWithConstraint:self.generalDistanceFromCenter withMinusSign:YES];

    self.nevermindButton.alpha = 0.0;
    self.titleLabel.alpha = 0.0;
    self.pencilView.alpha = 0.0;
}

- (void)renewFinalValuesForElements
{
    [self.animationsHelper renewFinalValueWithConstraint:self.generalDistanceFromCenter forKindOfElement:kGeneralElement];
    [self.animationsHelper renewFinalValueWithConstraint:self.announcementDistanceFromCenter forKindOfElement:kAnnouncementElement];
    [self.animationsHelper renewFinalValueWithConstraint:self.eventDistanceFromCenter forKindOfElement:kEventElement];
    [self.animationsHelper renewFinalValueWithConstraint:self.questionDistanceFromCenter forKindOfElement:kQuestionElement];
}

/**
 Renews the animation delays.
 
 @param appearing variable is YES when the views are going to be appeared. NO if they are going
 to be disappeared.
 */
- (void)renewAnimationDelaysForElementsForAppearing:(BOOL)appearing
{
    [self.animationsHelper renewDelay:(appearing) ? 0.1 : 0.2 withKindOfElement:kGeneralElement];
    [self.animationsHelper renewDelay:(appearing) ? 0.1 : 0.2 withKindOfElement:kQuestionElement];
    [self.animationsHelper renewDelay:(appearing) ? 0.2 : 0.1 withKindOfElement:kAnnouncementElement];
    [self.animationsHelper renewDelay:(appearing) ? 0.2 : 0.1 withKindOfElement:kEventElement];
}

- (void)renewDismissingAnimationDelays
{
    [self.animationsHelper renewDelay:0.05 withKindOfElement:kGeneralElement];
    [self.animationsHelper renewDelay:0.15 withKindOfElement:kQuestionElement];
    [self.animationsHelper renewDelay:0.05 withKindOfElement:kAnnouncementElement];
    [self.animationsHelper renewDelay:0.15 withKindOfElement:kEventElement];
    [self.animationsHelper renewDelay:0.15 withKindOfElement:kTitleElement];
    [self.animationsHelper renewDelay:0.15 withKindOfElement:kPencilElement];
}

#pragma mark - Animations

- (void)animateElementsAfterViewDidLoad
{
    [self.animationsHelper viewDidAppearAnimationWithConstraint:self.announcementDistanceFromBottom andKindOfElement:kAnnouncementElement];
    [self.animationsHelper viewDidAppearAnimationWithConstraint:self.generalDistanceFromBottom andKindOfElement:kGeneralElement];
    [self.animationsHelper viewDidAppearAnimationWithConstraint:self.pencilDistanceFromTop andKindOfElement:kPencilElement];
    [self.animationsHelper viewDidAppearAnimationWithConstraint:self.titleDistanceFromTop andKindOfElement:kTitleElement];
    [self.animationsHelper fadeView:self.nevermindButton withAppearance:YES];
}

- (void)animateElementsBeforeGoingForwardDisappearing
{
    for(UIView *view in self.elements)
    {
        [self.animationsHelper viewDisappearingAnimationWithView:view withKindOfElement:view.tag andViewDismiss:NO];
    }
}

- (void)animateElementsBeforeDismissing
{
    [self renewDismissingAnimationDelays];
    
    for(UIView *view in self.elements)
    {
        [self.animationsHelper viewDisappearingAnimationWithView:view withKindOfElement:view.tag andViewDismiss:YES];
    }
}

- (void)animateElementsAfterComingBack
{
    //[self.animationsHelper animateElementAfterComingBackWithConstraint:self.generalDistanceFromCenter andKindOfElement:kGeneralElement];
    
    [self.animationsHelper viewDidAppearAnimationWithConstraint:self.questionDistanceFromCenter andKindOfElement:kQuestionElement];
    [self.animationsHelper viewDidAppearAnimationWithConstraint:self.eventDistanceFromCenter andKindOfElement:kEventElement];
    [self.animationsHelper viewDidAppearAnimationWithConstraint:self.announcementDistanceFromCenter andKindOfElement:kAnnouncementElement];
    [self.animationsHelper viewDidAppearAnimationWithConstraint:self.generalDistanceFromCenter andKindOfElement:kGeneralElement];
    [self.animationsHelper fadeView:self.nevermindButton withAppearance:YES];
    [self.animationsHelper fadeView:self.titleLabel withAppearance:YES];
    [self.animationsHelper fadeView:self.pencilView withAppearance:YES];
}

#pragma mark - GLPIntroNewPostAnimationHelperDelegate

- (void)viewsDisappeared
{
    [self renewFinalValuesForElements];
    [self renewAnimationDelaysForElementsForAppearing:YES];
    [self setPositionsOnElementsAfterGoingForward];
    
    if(self.readyToGoToEventsView)
    {
        [self navigateToSelectEventView];
    }
    else if (self.readyToGoToGeneralView)
    {
        [self navigateToNewPostView];
    }
    else if (self.readyToGoToPollView)
    {
        [self navigateToPollView];
    }
}

- (void)viewReadyToBeDismissed
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

    [self animateElementsBeforeGoingForwardDisappearing];
    
    self.readyToGoToEventsView = YES;

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
    
    self.readyToGoToGeneralView = YES;

    [self animateElementsBeforeGoingForwardDisappearing];
}

- (IBAction)selectPoll:(id)sender
{
    if([[PendingPostManager sharedInstance] kindOfPost] != kPollPost)
    {
        [[PendingPostManager sharedInstance] reset];
    }
    
    [[PendingPostManager sharedInstance] setGroup:_group];
    
    [[PendingPostManager sharedInstance] setGroupPost:_groupPost];
    
    [[PendingPostManager sharedInstance] setKindOfPost:kPollPost];
    
    
    self.readyToGoToPollView = YES;
    [self animateElementsBeforeGoingForwardDisappearing];
}

- (IBAction)dismiss:(id)sender
{
    [self animateElementsBeforeDismissing];
}

#pragma mark - Navigation

- (void)navigateToNewPostView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"new_post" bundle:nil];
    NewPostViewController *newPostVC = [storyboard instantiateViewControllerWithIdentifier:@"NewPostViewController"];
    newPostVC.comesFromFirstView = YES;
    [self.navigationController pushViewController:newPostVC animated:NO];
}

- (void)navigateToSelectEventView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"new_post" bundle:nil];
    IntroKindOfEventViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"IntroKindOfEventViewController"];
    [self.navigationController pushViewController:cvc animated:NO];
}

- (void)navigateToPollView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"new_post" bundle:nil];
    NewPostViewController *newPostVC = [storyboard instantiateViewControllerWithIdentifier:@"NewPostViewControllerPoll"];
    newPostVC.comesFromFirstView = YES;
    [self.navigationController pushViewController:newPostVC animated:NO];
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
