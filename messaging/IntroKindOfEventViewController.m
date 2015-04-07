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

@interface IntroKindOfEventViewController () <UINavigationControllerDelegate>

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
    [self initialiseObjects];
    [self initialisePositions];
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
}

- (void)initialisePositions
{
    [self.animationHelper setInitialValueInConstraint:self.calendarXAligment forView:self.calendarView];
    [self.animationHelper setInitialValueInConstraint:self.musicXAligment forView:self.musicView];
    [self.animationHelper setInitialValueInConstraint:self.partyXAligment forView:self.partyView];
    [self.animationHelper setInitialValueInConstraint:self.theaterXAligment forView:self.theaterView];
    [self.animationHelper setInitialValueInConstraint:self.freeFoodXAligment forView:self.freeFoodView];
    [self.animationHelper setInitialValueInConstraint:self.sportsXAligment forView:self.sportsView];
    [self.animationHelper setInitialValueInConstraint:self.otherXAligment forView:self.otherView];
    [self.animationHelper setInitialValueInConstraint:self.speakerXAligment forView:self.speakersView];
    [self.titleLabel setAlpha:0.0];
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
    [self.animationHelper animateNevermindView:self.titleLabel withAppearance:YES];
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
    
    
    [self navigateToDatePickerView];
//    [self performSegueWithIdentifier:@"pick date" sender:self];

}

- (void)navigateToDatePickerView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"new_post" bundle:nil];
    IntroKindOfEventViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"PickDateEventViewController"];
    [self.navigationController pushViewController:cvc animated:NO];
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
