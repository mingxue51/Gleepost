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

@interface PickDateEventViewController () <UINavigationControllerDelegate, GLPPickTimeAnimationHelperDelegate>

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) FakeNavigationBarNewPostView *fakeNavigationBar;

@property (strong, nonatomic) GLPPickTimeAnimationHelper *animationHelper;

//Constraints.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timePickerXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonXAligment;

//Views.
@property (weak, nonatomic) IBOutlet UIView *nextButton;
@property (weak, nonatomic) IBOutlet UIView *titleLabel;

@end

@implementation PickDateEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialiseObjects];
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
    [self.fakeNavigationBar selectDotWithNumber:3];
    [self.view addSubview:self.fakeNavigationBar];
    
    [self.navigationController.navigationBar invisible];
}

- (void)configureCustomBackButton
{
    // change the back button to cancel and add an event handler
    self.navigationItem.leftBarButtonItems = [GLPApplicationHelper customBackButtonWithTarget:self];
}

- (void)initialiseObjects
{
    self.animationHelper = [[GLPPickTimeAnimationHelper alloc] init];
    self.animationHelper.delegate = self;
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
    NSDate* now = [NSDate date];
    
    // Get current NSDate without seconds & milliseconds, so that I can better compare the chosen date to the minimum & maximum dates.
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* nowWithoutSecondsComponents = [calendar components:
                                                     (NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:now] ;
    
    NSDate* nowWithoutSeconds = [calendar dateFromComponents:nowWithoutSecondsComponents] ;

    _datePicker.minimumDate = nowWithoutSeconds;
    
    
    //TODO: Uncomment the following code to set maximum date. More here: http://stackoverflow.com/questions/14694452/uidatepicker-set-maximum-date
//    NSDateComponents* addOneMonthComponents = [NSDateComponents new] ;
//    addOneMonthComponents.month = 1 ;
//    NSDate* oneMonthFromNowWithoutSeconds = [calendar dateByAddingComponents:addOneMonthComponents toDate:nowWithoutSeconds options:0] ;
//    picker.maximumDate = oneMonthFromNowWithoutSeconds ;
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

-(IBAction)dismissViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)continueToTheFinalView:(id)sender
{
    [[PendingPostManager sharedInstance] setDate:_datePicker.date];

    [self animateElementsBeforeGoingBack:NO];
}

- (void)navigateToNewPostView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"new_post" bundle:nil];
    NewPostViewController *newPostVC = [storyboard instantiateViewControllerWithIdentifier:@"NewPostViewController"];
    [self.navigationController pushViewController:newPostVC animated:NO];
}

- (void)backButtonTapped
{
    [self animateElementsBeforeGoingBack:YES];
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
