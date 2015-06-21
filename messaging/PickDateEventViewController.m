//
//  PickDateEventViewController.m
//  Gleepost
//
//  Created by Silouanos on 10/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "PickDateEventViewController.h"
#import "WebClientHelper.h"
#import "PendingPostManager.h"
#import "ATNavigationNewPost.h"
#import "UINavigationBar+Format.h"
#import "FakeNavigationBarNewPostView.h"
#import "GLPPickTimeAnimationHelper.h"
#import "GLPApplicationHelper.h"
#import "GLPPostUploader.h"
#import "DateFormatterHelper.h"

@interface PickDateEventViewController () <UINavigationControllerDelegate, GLPPickTimeAnimationHelperDelegate>

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) FakeNavigationBarNewPostView *fakeNavigationBar;

@property (strong, nonatomic) GLPPickTimeAnimationHelper *animationHelper;

/** Post uploader is used for uploading a poll post. */
@property (strong, nonatomic) GLPPostUploader *postUploader;

//Constraints.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timePickerXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonXAligment;

//Views.
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation PickDateEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialiseObjects];
    [self configureElementsIfPoll];
    [self configureCustomBackButton];
    [self setUpDatePicker];
    [self loadDateIfNeeded];
    [self cofigureNavigationBar];
    [self preparePositionsBeforeIntro:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    DDLogDebug(@"PickDate viewWillDisappear : %@", _datePicker.date);
    
    //Save date before desappearing the view.
    [[PendingPostManager sharedInstance] setDate:_datePicker.date];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
    [self animateElementsAfterViewDidLoad];
}

- (void)cofigureNavigationBar
{
    self.fakeNavigationBar = [[FakeNavigationBarNewPostView alloc] init];
    
    if(self.isNewPoll)
    {
        [self.fakeNavigationBar setThreeDotsMode];
    }
    
    [self.fakeNavigationBar selectDotWithNumber:3];
    [self.view addSubview:self.fakeNavigationBar];
    
    [self.navigationController.navigationBar invisible];
}

- (void)configureCustomBackButton
{
    // change the back button to cancel and add an event handler
    self.navigationItem.leftBarButtonItems = [GLPApplicationHelper customBackButtonWithTarget:self];
}

- (void)configureElementsIfPoll
{
    if(self.isNewPoll)
    {
        self.titleLabel.text = @"When do you want this poll to end?";
        [self.nextButton setTitle:@"FINISHED" forState:UIControlStateNormal];
    }
}

- (void)initialiseObjects
{
    self.animationHelper = [[GLPPickTimeAnimationHelper alloc] init];
    self.animationHelper.delegate = self;
    
    if(self.isNewPoll)
    {
        self.postUploader = [[GLPPostUploader alloc] init];
        
        if(self.pollImage)
        {
            [self.postUploader uploadImageToQueue:self.pollImage];
        }
    }
}

#pragma mark - Animation configuration

- (void)preparePositionsBeforeIntro:(BOOL)beforeIntro
{
    [self.animationHelper setInitialValueInConstraint:self.timePickerXAligment forView:self.datePicker comingFromRight:beforeIntro];
    [self.animationHelper setInitialValueInConstraint:self.titleXAligment forView:self.titleLabel comingFromRight:beforeIntro];
    [self.animationHelper setInitialValueInConstraint:self.buttonXAligment forView:self.nextButton comingFromRight:beforeIntro];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Animations

- (void)animateElementsAfterViewDidLoad
{
    [self.animationHelper viewDidLoadAnimationWithConstraint:self.timePickerXAligment withKindOfElement:kTimeElement];
    [self.animationHelper viewDidLoadAnimationWithConstraint:self.buttonXAligment withKindOfElement:kButtonElement];
    [self.animationHelper viewDidLoadAnimationWithConstraint:self.titleXAligment withKindOfElement:kTitleElement];
}

- (void)animateElementsBeforeGoingBack:(BOOL)goingBack
{
    [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.datePicker andKindOfElement:kTimeElement];
    [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.titleLabel andKindOfElement:kTitleElement];
    [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.nextButton andKindOfElement:kButtonElement];
}

#pragma mark - Initialisations

-(void)setUpDatePicker
{
    NSDate *minimimDate = [NSDate date];
    
    if([self isNewPoll])
    {
        minimimDate = [DateFormatterHelper generateDateAfterMinutes:17];
    }
    
    _datePicker.minimumDate = minimimDate;
    
    if([self isNewPoll])
    {
        _datePicker.maximumDate = [DateFormatterHelper generateDateAfterDays:31];
    }
}

- (void)loadDateIfNeeded
{
    if(![[PendingPostManager sharedInstance] arePendingData])
    {
        return;
    }
    
    if([[PendingPostManager sharedInstance] getDate])
    {
        [_datePicker setDate:[[PendingPostManager sharedInstance] getDate]];
    }
    
}

#pragma mark - GLPPickTimeAnimationHelperDelegate

- (void)goingBackViewsDisappeared
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)goingForwardViewsDisappeared
{
    [self preparePositionsBeforeIntro:NO];
    [self navigateToNewPostView];
}

#pragma mark - Actions

-(IBAction)dismissViewController
{
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //Dismiss view controller and show immediately the post in the Campus Wall.
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

-(IBAction)continueToTheFinalView:(id)sender
{
    if(self.isNewPoll)
    {
        //Create the poll and dismiss the view controller.
        [[PendingPostManager sharedInstance] setDate:_datePicker.date];
        [self createPollPostAndDismissView];
        return;
    }
    
    [[PendingPostManager sharedInstance] setDate:_datePicker.date];
    [self animateElementsBeforeGoingBack:NO];
}

- (void)createPollPostAndDismissView
{
    DDLogDebug(@"PickDateVC createPollPostAndDismissView post %@", [[PendingPostManager sharedInstance] getPendingPost]);
    
    [self.postUploader uploadPollPostWithPost:[[PendingPostManager sharedInstance] getPendingPost]];
    [self informParentVCForNewPollPost:[[PendingPostManager sharedInstance] getPendingPost]];
    [[PendingPostManager sharedInstance] reset];
    [self dismissViewController];
}

- (void)navigateToNewPostView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"new_post" bundle:nil];
    NewPostViewController *newPostVC = [storyboard instantiateViewControllerWithIdentifier:@"NewPostViewController"];
    newPostVC.comesFromFirstView = NO;
    [self.navigationController pushViewController:newPostVC animated:NO];
}

- (void)backButtonTapped
{
    [self animateElementsBeforeGoingBack:YES];
}

- (void)informParentVCForNewPollPost:(GLPPost *)post
{
    if([[PendingPostManager sharedInstance] isGroupPost])
    {
        //Notify the group view controller.
        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_RELOAD_DATA_IN_GVC object:nil userInfo:@{@"new_post": post}];
    }
    else
    {
        //Notify campus wall.
        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_RELOAD_DATA_IN_CW object:nil userInfo:@{@"new_post": post}];
    }
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

@end
