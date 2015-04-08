//
//  IntorKinfOfEventViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 14/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "IntroKindOfEventViewController.h"
#import "PendingPostManager.h"
#import "CategoryManager.h"
#import "UINavigationBar+Format.h"
#import "GLPiOSSupportHelper.h"
#import "ATNavigationNewPost.h"
#import "FakeNavigationBarNewPostView.h"
#import "GLPEventNewPostAnimationHelper.h"
#import "GLPApplicationHelper.h"

@interface IntroKindOfEventViewController () <UINavigationControllerDelegate, GLPEventNewPostAnimationHelperDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distancePartyButtonFromTop;
@property (nonatomic, retain) IBOutletCollection(NSLayoutConstraint) NSArray *distancesBetweenButtons;
@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

//Constraints.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *partyXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *musicXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *theaterXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *freeFoodXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sportsXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speakerXAligment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherXAligment;

//Views.
@property (weak, nonatomic) IBOutlet UIView *calendarView;
@property (weak, nonatomic) IBOutlet UIView *partyView;
@property (weak, nonatomic) IBOutlet UIView *musicView;
@property (weak, nonatomic) IBOutlet UIView *theaterView;
@property (weak, nonatomic) IBOutlet UIView *freeFoodView;
@property (weak, nonatomic) IBOutlet UIView *sportsView;
@property (weak, nonatomic) IBOutlet UIView *speakersView;
@property (weak, nonatomic) IBOutlet UIView *otherView;


@property (strong, nonatomic) FakeNavigationBarNewPostView *fakeNavigationBar;

@property (strong, nonatomic) GLPEventNewPostAnimationHelper *animationHelper;

@end

@implementation IntroKindOfEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCustomBackButton];
    [self initialiseObjects];
    [self preparePositionsBeforeIntro:YES];
    [self configureNavigationBar];
    [self configureConstrainsDependingOnScreenSize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    self.distancePartyButtonFromTop.constant = (self.topButton.frame.origin.y / 2) - (self.titleLabel.frame.size.height / 2);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
    [self animateElementsAfterViewDidLoad];
}

- (void)initialiseObjects
{
    self.animationHelper = [[GLPEventNewPostAnimationHelper alloc] init];
    self.animationHelper.delegate = self;
}

- (void)configureNavigationBar
{
    self.fakeNavigationBar = [[FakeNavigationBarNewPostView alloc] init];
    [self.view addSubview:self.fakeNavigationBar];
    
    [self.navigationController.navigationBar invisible];

    
//    self.title = @"NEW POST";
    
//    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
}

- (void)configureConstrainsDependingOnScreenSize
{
    if([GLPiOSSupportHelper useShortConstrains])
    {
        for(NSLayoutConstraint *constraint in self.distancesBetweenButtons)
        {
            constraint.constant = 5.0;
        }
    }
}

- (void)configureCustomBackButton
{
    // change the back button to cancel and add an event handler
    self.navigationItem.leftBarButtonItems = [GLPApplicationHelper customBackButtonWithTarget:self];
}

#pragma mark - Animation configuration

- (void)preparePositionsBeforeIntro:(BOOL)beforeIntro
{
    [self.animationHelper setInitialValueInConstraint:self.calendarXAligment forView:self.calendarView withMinusSign:beforeIntro];
    [self.animationHelper setInitialValueInConstraint:self.musicXAligment forView:self.musicView withMinusSign:beforeIntro];
    [self.animationHelper setInitialValueInConstraint:self.partyXAligment forView:self.partyView withMinusSign:beforeIntro];
    [self.animationHelper setInitialValueInConstraint:self.theaterXAligment forView:self.theaterView withMinusSign:beforeIntro];
    [self.animationHelper setInitialValueInConstraint:self.freeFoodXAligment forView:self.freeFoodView withMinusSign:beforeIntro];
    [self.animationHelper setInitialValueInConstraint:self.sportsXAligment forView:self.sportsView withMinusSign:beforeIntro];
    [self.animationHelper setInitialValueInConstraint:self.otherXAligment forView:self.otherView withMinusSign:beforeIntro];
    [self.animationHelper setInitialValueInConstraint:self.speakerXAligment forView:self.speakersView withMinusSign:beforeIntro];
    [self.titleLabel setAlpha:0.0];
}

- (void)preparePositionsAfterGoingForward
{
    [self preparePositionsBeforeIntro:NO];
}

- (void)setDelayFromLeftToRight
{
    [self.animationHelper renewDelay:0.25 withKindOfElement:kPartiesElement];
    [self.animationHelper renewDelay:0.25 withKindOfElement:kSportsElement];
    [self.animationHelper renewDelay:0.2 withKindOfElement:kMusicElement];
    [self.animationHelper renewDelay:0.2 withKindOfElement:kFreeFoodElement];
    [self.animationHelper renewDelay:0.2 withKindOfElement:kSpeakersElement];
    [self.animationHelper renewDelay:0.1 withKindOfElement:kOtherElement];
    [self.animationHelper renewDelay:0.1 withKindOfElement:kTheaterElement];
}

- (void)setDelayFromRightToLeft
{
    [self.animationHelper renewDelay:0.1 withKindOfElement:kPartiesElement];
    [self.animationHelper renewDelay:0.1 withKindOfElement:kSportsElement];
    [self.animationHelper renewDelay:0.2 withKindOfElement:kMusicElement];
    [self.animationHelper renewDelay:0.2 withKindOfElement:kFreeFoodElement];
    [self.animationHelper renewDelay:0.2 withKindOfElement:kSpeakersElement];
    [self.animationHelper renewDelay:0.25 withKindOfElement:kOtherElement];
    [self.animationHelper renewDelay:0.25 withKindOfElement:kTheaterElement];
}

#pragma mark - Animations

- (void)animateElementsAfterViewDidLoad
{
    [self.animationHelper viewDidLoadAnimationWithConstraint:self.calendarXAligment withKindOfElement:kCalendarElement];
    [self.animationHelper viewDidLoadAnimationWithConstraint:self.musicXAligment withKindOfElement:kMusicElement];
    [self.animationHelper viewDidLoadAnimationWithConstraint:self.partyXAligment withKindOfElement:kPartiesElement];
    [self.animationHelper viewDidLoadAnimationWithConstraint:self.theaterXAligment withKindOfElement:kTheaterElement];
    [self.animationHelper viewDidLoadAnimationWithConstraint:self.freeFoodXAligment withKindOfElement:kFreeFoodElement];
    [self.animationHelper viewDidLoadAnimationWithConstraint:self.sportsXAligment withKindOfElement:kSportsElement];
    [self.animationHelper viewDidLoadAnimationWithConstraint:self.speakerXAligment withKindOfElement:kSpeakersElement];
    [self.animationHelper viewDidLoadAnimationWithConstraint:self.otherXAligment withKindOfElement:kOtherElement];
    [self.animationHelper fadeView:self.titleLabel withAppearance:YES];
}

- (void)animateElementsBeforeGoingBack:(BOOL)goingBack
{
    [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.calendarView andKindOfElement:kCalendarElement];
    [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.musicView andKindOfElement:kMusicElement];
    [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.partyView andKindOfElement:kPartiesElement];
    [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.theaterView andKindOfElement:kTheaterElement];
    [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.freeFoodView andKindOfElement:kFreeFoodElement];
    [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.sportsView andKindOfElement:kSportsElement];
    [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.otherView andKindOfElement:kOtherElement];
    [self.animationHelper viewGoingBack:goingBack disappearingAnimationWithView:self.speakersView andKindOfElement:kSpeakersElement];
    [self.animationHelper fadeView:self.titleLabel withAppearance:NO];
}

#pragma mark - GLPEventNewPostAnimationHelperDelegate

- (void)goingBackViewsDisappeared
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)goingForwardViewsDisappeared
{
    [self preparePositionsAfterGoingForward];
    [self setDelayFromLeftToRight];
    [self navigateToDatePickerView];
}

#pragma mark - Selectors

- (IBAction)selectCategory:(UIButton *)senderButton
{
//    switch (senderButton.tag) {
//        case 1:
//            //Party selected.
//            break;
//            
//        case 2:
//            //Music selected.
//            break;
//            
//        case 3:
//            //Sports selected.
//            break;
//            
//        case 4:
//            //Theater selected.
//            break;
//            
//        case 5:
//            //Speaker selected.
//            break;
//            
//        case 6:
//            //Other selected.
//            break;
//            
//        default:
//            break;
//    }
    
    DDLogInfo(@"Category selected: %@", [[CategoryManager sharedInstance] categoryWithOrderKey:senderButton.tag]);
    
    [[PendingPostManager sharedInstance] setCategory: [[CategoryManager sharedInstance] categoryWithOrderKey:senderButton.tag]];
    
    [self setDelayFromRightToLeft];
    [self animateElementsBeforeGoingBack:NO];
    
//    [self performSegueWithIdentifier:@"pick date" sender:self];

}

- (void)navigateToDatePickerView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"new_post" bundle:nil];
    IntroKindOfEventViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"PickDateEventViewController"];
    [self.navigationController pushViewController:cvc animated:NO];
}

- (void)backButtonTapped
{
    [self setDelayFromLeftToRight];
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
